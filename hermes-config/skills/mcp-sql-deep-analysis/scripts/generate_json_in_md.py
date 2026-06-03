#!/usr/bin/env python3
"""
解析单个 .prc 文件，生成「取数范围」和「字段取值」两个 JSON-in-Markdown 文件。

用法（通过 execute_code）：
    import sys
    sys.path.insert(0, f'{PROJECT_ROOT}/scripts')
    from generate_json_in_md import process_prc_file
    process_prc_file(prc_path, entity_name, out_range_dir, out_field_dir)

输出格式：
    实体/取数范围/{entity}.md  — 含 JSON 代码块的取数范围文档
    实体/字段取值/{entity}.md  — 含 JSON 代码块的字段取值文档
"""

import json, os, re
from datetime import datetime


def classify_join(j: dict) -> dict:
    """根据 JOIN 类型判定角色：INNER → 过滤，其他 → 仅字段补充"""
    jtype = j.get('type', '').upper()
    return {
        'type': jtype,
        'table': j.get('table', ''),
        'alias': j.get('alias', ''),
        'on_conditions': j.get('on_conditions', []),
        'role': '过滤' if jtype == 'INNER' else '仅字段补充'
    }


def is_business_where(w: str) -> bool:
    """排除非业务 WHERE 条件（分区管理、硬编码修正、MERGE 匹配等）"""
    skip_kw = [
        'TABLE_NAME', 'PARTITION_NAME',
        'DATA_DATE = VS_TEXT8', 'CJRQ = IS_DATE', 'CJRQ = VS_LAST_TEXT',
        "CUST_ID_NO = 'G102", "CUST_NAME = '",
        "ORG_AREA_COD = '", "REG_AREA_CODE = '",
        "A.FRNBJGH = '990000'", "FRNBJGH = '990000'",
        "B.FRNBJGH = '990000'",
        "SUBSTRING(A.DEPT_TYPE", "NOT SUBSTRING(DEPT_TYPE",
        "CUST_NAME LIKE '%", "ENT_SCALE IN (",
    ]
    for kw in skip_kw:
        if kw in w:
            return False
    return True


def get_statement_label(line_num: int) -> str:
    """根据行号给语句打标签（金融基础数据报送系统项目特定映射）"""
    # 项目特定映射，可扩展
    label_map = {
        105: '放款数据（贷款发放 - INSERT INTO 主SELECT）',
        478: '还款数据（贷款收回 - 子SELECT）',
        917: '中间表汇总（从临时表取数）',
        1012: '最终INSERT（写入目标表）',
    }
    return label_map.get(line_num, f'line {line_num}')


def process_prc_file(prc_path: str, entity_name: str,
                     out_range_dir: str, out_field_dir: str,
                     mcp_sql_parser_module) -> dict | None:
    """
    解析一个 .prc 文件，生成 JSON-in-MD 文件。

    参数：
        prc_path: .prc 文件绝对路径
        entity_name: 实体名称（如 "单位贷款发生额信息_JS_201_DWDKFS"）
        out_range_dir: 取数范围输出目录
        out_field_dir: 字段取值输出目录
        mcp_sql_parser_module: 已导入的 mcp_sql_parser 模块

    返回：
        成功时返回 {'range_path': ..., 'field_path': ..., 'stats': ...}
        无有效结果时返回 None
    """
    extract_sql_from_plsql = mcp_sql_parser_module.extract_sql_from_plsql
    parse_single_sql = mcp_sql_parser_module.parse_single_sql

    with open(prc_path, 'r', encoding='utf-8') as f:
        content = f.read()

    stmts = extract_sql_from_plsql(content)

    # 筛选关键语句：跳过 SELECT INTO 变量、COUNT 检查
    KEY_TYPES = ('INSERT', 'SELECT')
    key_stmts = []
    for s in stmts:
        if s['type'] not in KEY_TYPES:
            continue
        sql = s['sql'].strip()
        if sql.upper().startswith('SELECT') and (
            'INTO ' in sql.upper()[:200] or sql.upper().startswith('SELECT COUNT(')
        ):
            continue
        try:
            parsed = parse_single_sql(sql)
        except Exception:
            continue
        key_stmts.append({
            'line': s['line'],  # 注意：extract_sql_from_plsql 返回 'line' 不是 'source_line'
            'type': s['type'],
            'parsed': parsed,
        })

    if not key_stmts:
        return None

    # 组装 data_extractions
    data_extractions = []
    for ks in key_stmts:
        p = ks['parsed']

        source_tables = [
            {'table': t.get('full_name', ''), 'alias': t.get('alias', '')}
            for t in p.get('tables', [])
        ]
        joins = [classify_join(j) for j in p.get('joins', [])]
        all_wheres = p.get('where_conditions', [])
        business_wheres = [w for w in all_wheres if is_business_where(w)]

        field_mappings = []
        for col in p.get('select_columns', []):
            field_mappings.append({
                'expression': col.get('expression', ''),
                'alias': col.get('alias', '')
            })

        data_extractions.append({
            'label': get_statement_label(ks['line']),
            'source_line': ks['line'],
            'type': ks['type'],
            'source_tables': source_tables,
            'joins': joins,
            'business_where_conditions': business_wheres,
            'field_count': len(field_mappings),
            'field_mappings': field_mappings,
        })

    dt = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    prc_filename = os.path.basename(prc_path)

    # 取数范围 JSON
    range_json = {
        'file': prc_path,
        'entity': entity_name,
        'parse_date': dt,
        'total_statements': len(stmts),
        'key_extractions': len(data_extractions),
        'data_extractions': [
            {
                'label': de['label'],
                'source_line': de['source_line'],
                'type': de['type'],
                'source_tables': de['source_tables'],
                'joins': de['joins'],
                'business_where_conditions': de['business_where_conditions'],
            }
            for de in data_extractions
        ]
    }

    # 字段取值 JSON
    field_json = {
        'file': prc_path,
        'entity': entity_name,
        'parse_date': dt,
        'data_extractions': [
            {
                'label': de['label'],
                'source_line': de['source_line'],
                'type': de['type'],
                'field_count': de['field_count'],
                'field_mappings': de['field_mappings'],
            }
            for de in data_extractions
        ]
    }

    os.makedirs(out_range_dir, exist_ok=True)
    os.makedirs(out_field_dir, exist_ok=True)

    # 写入取数范围
    range_md = (
        f"# {entity_name} — 取数范围\n\n"
        f"> 来源程序: `{prc_filename}`\n"
        f"> 解析日期: {dt}\n"
        f"> 语句总数: {len(stmts)}，关键取数语句: {len(data_extractions)}\n\n"
        f"```json\n{json.dumps(range_json, ensure_ascii=False, indent=2)}\n```\n"
    )
    range_path = os.path.join(out_range_dir, f'{entity_name}.md')
    with open(range_path, 'w', encoding='utf-8') as f:
        f.write(range_md)

    # 写入字段取值
    field_md = (
        f"# {entity_name} — 字段取值\n\n"
        f"> 来源程序: `{prc_filename}`\n"
        f"> 解析日期: {dt}\n\n"
        f"```json\n{json.dumps(field_json, ensure_ascii=False, indent=2)}\n```\n"
    )
    field_path = os.path.join(out_field_dir, f'{entity_name}.md')
    with open(field_path, 'w', encoding='utf-8') as f:
        f.write(field_md)

    return {
        'range_path': range_path,
        'field_path': field_path,
        'stats': {
            'total_stmts': len(stmts),
            'key_stmts': len(data_extractions),
            'range_size': os.path.getsize(range_path),
            'field_size': os.path.getsize(field_path),
        }
    }
