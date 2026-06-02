#!/usr/bin/env python3
"""
批量解析 .prc 文件，为每个报表生成「取数范围」和「字段取值」两个 Markdown 文档。

用法：将此脚本放在项目根目录，通过 execute_code 运行。
需要预先安装 sqlglot，且项目 scripts/ 目录下有 mcp_sql_parser.py。

核心函数：
  extract_sql_from_plsql(content: str) -> list[dict]   # [{type, sql, line}, ...]
  parse_single_sql(sql: str) -> dict                    # {tables, joins, where_conditions, select_columns}
"""

import sys, os, re

# --- 配置区域（根据项目调整） ---
PROJECT_ROOT = '/mnt/e/workspace/金融基础数据报送系统'
PRC_DIR = f'{PROJECT_ROOT}/源码解析/加工层存储'
ENTITY_DIR = f'{PROJECT_ROOT}/实体'
OUT_RANGE = f'{ENTITY_DIR}/取数范围'
OUT_FIELD = f'{ENTITY_DIR}/字段取值'

sys.path.insert(0, f'{PROJECT_ROOT}/scripts')
from mcp_sql_parser import extract_sql_from_plsql, parse_single_sql


def find_entity_name(code_upper: str, batch: str, entity_files_list: list[str]) -> str:
    """根据接口表代码匹配实体文件名"""
    full_code = f'JS_{batch}_{code_upper}'
    for ef in entity_files_list:
        if full_code in ef:
            return ef.replace('.md', '')
    for ef in entity_files_list:
        if code_upper in ef.upper().replace('_', ''):
            return ef.replace('.md', '')
    return full_code  # 回退


def process_prc_file(prc_path: str, prc_filename: str, entity_name: str) -> tuple[str, str] | None:
    """
    解析单个 .prc 文件，返回 (取数范围_md, 字段取值_md) 或 None。
    """
    with open(prc_path, 'r', encoding='utf-8') as f:
        content = f.read()

    stmts = extract_sql_from_plsql(content)

    all_wheres = []
    all_joins = []
    all_fields = []

    for s in stmts:
        if s['type'] not in ('SELECT', 'INSERT'):
            continue
        try:
            parsed = parse_single_sql(s['sql'])
        except Exception:
            continue

        for w in parsed.get('where_conditions', []):
            w_clean = w.strip()
            if w_clean and w_clean not in all_wheres:
                all_wheres.append(w_clean)

        for j in parsed.get('joins', []):
            j_str = f"{j.get('type','')} JOIN {j.get('table','')} ON {' AND '.join(j.get('on_conditions',[]))}"
            if j_str not in all_joins:
                all_joins.append(j_str)

        for col in parsed.get('select_columns', []):
            expr = col.get('expression', '')
            alias = col.get('alias', '')
            if expr and expr not in [f[0] for f in all_fields]:
                all_fields.append((expr, alias))

    if not all_wheres and not all_joins:
        return None  # 没有有意义的解析结果

    # --- 取数范围 ---
    tables_set = set()
    for j in all_joins:
        parts = j.split(' JOIN ')
        if len(parts) > 1:
            tables_set.add(parts[1].split(' ON ')[0])

    range_md = f"""# {entity_name} — 取数范围

> 来源程序: `{prc_filename}`

## 数据源表（FROM）

"""
    for t in sorted(tables_set):
        range_md += f"- {t}\n"

    range_md += "\n## 关联条件（JOIN）\n\n"
    for j in all_joins:
        range_md += f"- {j}\n"

    range_md += "\n## 筛选条件（WHERE）\n\n"
    for i, w in enumerate(all_wheres, 1):
        range_md += f"{i}. `{w}`\n"

    # --- 字段取值 ---
    field_md = f"""# {entity_name} — 字段取值

> 来源程序: `{prc_filename}`

## 字段映射

| 序号 | 目标字段(alias) | 源表达式(expression) |
|------|----------------|---------------------|
"""
    for i, (expr, alias) in enumerate(all_fields, 1):
        alias_str = alias if alias else '(无)'
        expr_short = expr[:200] + '...' if len(expr) > 200 else expr
        expr_esc = expr_short.replace('|', '\\|')
        field_md += f"| {i} | `{alias_str}` | `{expr_esc}` |\n"

    return range_md, field_md


def main():
    os.makedirs(OUT_RANGE, exist_ok=True)
    os.makedirs(OUT_FIELD, exist_ok=True)

    # 获取所有 .prc 文件（排除 _his 版本、辅助程序）
    prc_files = sorted([
        f for f in os.listdir(PRC_DIR)
        if f.endswith('.prc')
        and '_his' not in f
        and 'spop' not in f
        and 'pbocd_table' not in f
    ])

    entity_files_list = [f for f in os.listdir(ENTITY_DIR) if f.endswith('.md')]

    success = 0
    fail = 0

    for pf in prc_files:
        prc_path = os.path.join(PRC_DIR, pf)
        match = re.search(r'bsp_sp_js_(\d+)_(.+)\.prc', pf)
        if not match:
            continue
        batch = match.group(1)
        code = match.group(2).upper()

        entity_name = find_entity_name(code, batch, entity_files_list)

        try:
            result = process_prc_file(prc_path, pf, entity_name)
            if result is None:
                continue
            range_md, field_md = result

            with open(os.path.join(OUT_RANGE, f'{entity_name}.md'), 'w', encoding='utf-8') as f:
                f.write(range_md)
            with open(os.path.join(OUT_FIELD, f'{entity_name}.md'), 'w', encoding='utf-8') as f:
                f.write(field_md)

            success += 1
        except Exception as e:
            print(f"FAIL [{pf}]: {e}")
            fail += 1

    print(f"Done: {success} success, {fail} fail, {len(prc_files)} total")


if __name__ == '__main__':
    main()
