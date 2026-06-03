#!/usr/bin/env python3
"""
batch-enrich.py — 批量增强源码头部注释 + 同步实体文档

处理流程：
  读取源码 → 解析注释 → 提取SMTMODS表引用 → 查监管集市表中名
  → 构建增强注释头部 → 写回源码 → 同步更新实体文档

适用场景：
  - Oracle PL/SQL 存储过程（.prc），GBK编码，有标准注释块
  - 加工层/应用层 SQL 脚本（.sql），无标准注释块
  - 实体文档（.md）已存在，需新增监管集市表依赖关系表格

前置条件：
  1. /tmp/table_map.json 已存在（从监管集市表清单.md解析得到）
  2. 三个目录配好：
     SRC_DIR = "源码解析/加工层存储"
     ENT_DIR = "实体/加工层存储"
     EXT     = ".prc"
"""

import re
import json
import os

BASE = "/mnt/e/workspace/金数源码"

# === 配置：此处需按项目修改 ===
DIRS = [
    {"src": f"{BASE}/源码解析/加工层存储", "ent": f"{BASE}/实体/加工层存储", "ext": ".prc", "biz": "加工层存储"},
    {"src": f"{BASE}/源码解析/加工层特殊处理", "ent": f"{BASE}/实体/加工层特殊处理", "ext": ".sql", "biz": "加工层特殊处理"},
    {"src": f"{BASE}/源码解析/应用层特殊处理", "ent": f"{BASE}/实体/应用层特殊处理", "ext": ".sql", "biz": "应用层特殊处理"},
]

# === 加载表映射（前置步骤产生） ===
with open("/tmp/table_map.json", "r", encoding="utf-8") as f:
    TABLE_MAP = json.load(f)

# === 业务域映射（从文件名数字前缀推断） ===
BIZ_MAP = {
    "101": "存款类 — 金融机构负债",
    "102": "客户信息类",
    "201": "贷款类",
    "202": "存款类",
    "203": "债券/投资类",
    "205": "票据类",
}

# ===================================================
# 编码工具
# ===================================================

def read_gbk(path):
    """以GBK读取，fallback到UTF-8"""
    with open(path, "rb") as f:
        raw = f.read()
    try:
        return raw.decode("gbk")
    except:
        return raw.decode("utf-8", errors="replace")

def write_gbk(path, content):
    """以GBK编码写入（！重要：保持Oracle文件的原编码）"""
    with open(path, "wb") as f:
        f.write(content.encode("gbk"))

def read_utf8(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def write_utf8(path, content):
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

# ===================================================
# 提取工具
# ===================================================

def extract_smtmods_tables(text):
    """从SQL文本中提取所有SMTMODS.xxx表引用（不区分大小写，统一大写）"""
    tables = set()
    for m in re.finditer(r'SMTMODS\.(\w+)', text, re.IGNORECASE):
        tables.add(m.group(1).upper())
    return sorted(tables)

def extract_pbocd_tables(text):
    """提取所有PBOCD_xxx接口表"""
    tables = set()
    for m in re.finditer(r'(PBOCD_\w+)', text):
        tables.add(m.group(0))
    return sorted(tables)

def get_biz_domain(filename):
    for prefix, domain in BIZ_MAP.items():
        if f"_{prefix}_" in filename or f"js_{prefix}" in filename.lower():
            return domain
    return "其他"

def parse_prc_header(header_text):
    """解析.prc头部注释的元信息"""
    purpose = output_table = history_text = None
    params_list = []
    if not header_text:
        return purpose, output_table, params_list, history_text
    m = re.search(r'用途[：:]\s*(.*?)(?:\n)', header_text)
    if m:
        purpose = m.group(1).strip()
    for m in re.finditer(r'(\w+)\s+(输入|输出)变量[，,]\s*(.*?)(?:\n)', header_text):
        params_list.append((m.group(1), m.group(2), m.group(3).strip()))
    m = re.search(r'(需求编号[：:].+?)(?:\n)', header_text)
    if m:
        history_text = m.group(1).strip()
    m = re.search(r'PBOCD_\w+', header_text)
    if m:
        output_table = m.group(0)
    return purpose, output_table, params_list, history_text

# ===================================================
# 构建工具
# ===================================================

def build_prc_header(proc_name, biz_domain, purpose, output_table,
                     tables, history_text, params_list):
    """构建增强后的.prc头部注释块（2空格缩进）"""
    lines = []
    sep = "  ------------------------------------------------------------------------------------------------------"
    lines.append(sep)
    lines.append("  -- 程序名")
    lines.append(f"  -- {proc_name}")
    lines.append(f"  -- 业务域: {biz_domain}")
    if purpose:
        lines.append(f"  -- 用途: {purpose}")
    if output_table:
        lines.append(f"  -- 输出接口表: {output_table}")
    if params_list:
        lines.append("  -- 参数")
        for name, direction, desc in params_list:
            lines.append(f"  --    {name} {direction}，{desc}")
    if tables:
        lines.append("  -- 引用的监管集市表")
        for t in tables:
            cn = TABLE_MAP.get(t, t)
            lines.append(f"  --    SMTMODS.{t:42s} — {cn}")
    if history_text:
        lines.append("  -- 修改历史")
        lines.append(f"  --    {history_text}")
    lines.append(sep)
    return "\n".join(lines)

# ===================================================
# .prc 处理
# ===================================================

def process_prc(prc_path, ent_path):
    if not os.path.exists(prc_path):
        return "[SKIP] 源文件不存在"
    content = read_gbk(prc_path)
    if not content:
        return "[SKIP] 无法读取"

    # 提取存储过程名
    m = re.search(r'CREATE\s+OR\s+REPLACE\s+PROCEDURE\s+(\w+)', content, re.I)
    if not m:
        return "[SKIP] 非存储过程"
    proc_name = m.group(1)

    # 提取头部注释块
    header_block = None
    m = re.search(r'(\s*-{70,}\s*\n)(.*?)(\n\s*-{70,})', content, re.DOTALL)
    if m:
        header_block = m.group(0)
        header_text = m.group(2)
    else:
        header_text = ""

    purpose, output_table, params_list, history_text = parse_prc_header(header_text)
    tables = extract_smtmods_tables(content)
    biz_domain = get_biz_domain(proc_name)

    new_header = build_prc_header(proc_name, biz_domain, purpose,
                                  output_table, tables, history_text, params_list)

    if header_block:
        new_content = content.replace(header_block, new_header, 1)
    else:
        new_content = content.replace("AS", f"AS\n{new_header}", 1)

    write_gbk(prc_path, new_content)
    process_entity(ent_path, f"{proc_name}.prc", biz_domain, purpose,
                   output_table, tables, history_text)
    return f"[OK] {proc_name}"

# ===================================================
# .sql 处理
# ===================================================

def process_sql(sql_path, ent_path, biz_category):
    if not os.path.exists(sql_path):
        return "[SKIP] 源文件不存在"
    content = read_utf8(sql_path)
    if not content:
        return "[SKIP] 无法读取"

    filename = os.path.basename(sql_path)
    tables = extract_smtmods_tables(content)
    pbocd_tables = extract_pbocd_tables(content)
    output_table = pbocd_tables[0] if pbocd_tables else None

    # 提取第一条注释作为用途
    purpose = None
    for line in content.split('\n'):
        line = line.strip()
        if line.startswith('--') and len(line) > 4:
            purpose = line.lstrip('-').strip()
            break
        elif line.startswith('/*') or line.startswith('/*--'):
            m = re.search(r'/\*[-]*\s*(.*?)(?:\n|$)', content)
            if m:
                purpose = m.group(1).strip()
            break

    biz_domain = get_biz_domain(filename) if "_" in filename else biz_category

    # 构建并插入头部注释
    sep_line = f"{'--' * 50}"
    header_lines = [sep_line, f"-- 文件名: {filename}", f"-- 业务域: {biz_domain}"]
    if purpose:
        header_lines.append(f"-- 用途: {purpose}")
    if output_table:
        header_lines.append(f"-- 操作接口表: {output_table}")
    if tables:
        header_lines.append("-- 引用的监管集市表:")
        for t in tables:
            cn = TABLE_MAP.get(t, t)
            header_lines.append(f"--   {t} — {cn}")
    header_lines.append(sep_line)
    header_text = "\n" + "\n".join(header_lines) + "\n"

    lines = content.split('\n')
    first_non_empty = 0
    for i, line in enumerate(lines):
        if line.strip():
            first_non_empty = i
            break
    lines.insert(first_non_empty, header_text)
    new_content = "\n".join(lines)

    write_utf8(sql_path, new_content)
    process_entity(ent_path, filename, biz_domain, purpose,
                   output_table, tables, history_text=None, is_sql=True)
    return f"[OK] {filename}"

# ===================================================
# 实体文档更新（两类型共用）
# ===================================================

def process_entity(ent_path, doc_title, biz_domain, purpose,
                   output_table, tables, history_text, is_sql=False):
    """保留已有内容，新增监管集市表依赖表格"""
    existing = read_utf8(ent_path) if os.path.exists(ent_path) else None

    # 提取并保留已有段落
    def extract_section(pattern, fallback=""):
        if not existing:
            return fallback
        m = re.search(pattern, existing, re.DOTALL)
        return m.group(1).strip() if m else fallback

    existing_purpose  = extract_section(r'## 用途说明\n(.*?)(?=\n## )')
    existing_func     = extract_section(r'## 功能概述\n(.*?)(?=\n## )')
    existing_logic    = extract_section(r'## 关键逻辑\n(.*?)(?=\n## |$)')
    existing_history  = extract_section(r'## 修改历史\n(.*?)(?=\n## |$)')

    # 提取已有依赖关系的用途列
    existing_usage = {}
    if existing:
        in_section = False
        for line in existing.split('\n'):
            if '## 依赖关系' in line:
                in_section = True
                continue
            if in_section:
                if line.startswith('## '):
                    break
                if line.strip().startswith('|') and '|' in line:
                    cols = [c.strip() for c in line.split('|')]
                    if len(cols) >= 4 and cols[1] and cols[1] != '表名' and cols[1] != '依赖对象':
                        existing_usage[cols[1]] = cols[3] if len(cols) >= 4 else ''

    # 构建
    parts = []
    parts.append(f"# {doc_title}\n")
    parts.append("## 基本元信息\n")
    parts.append("| 属性 | 值 |")
    parts.append("|------|-----|")
    if is_sql:
        parts.append("| 文件类型 | SQL脚本 |")
    else:
        parts.append(f"| 存储过程名 | {doc_title.replace('.prc','')} |")
    parts.append(f"| 业务域 | {biz_domain} |")
    if output_table:
        label = "操作接口表" if is_sql else "输出接口表"
        parts.append(f"| {label} | {output_table} |")
    parts.append("")

    parts.append("## 用途说明\n")
    parts.append(existing_purpose or purpose or "（待补充）")
    parts.append("")

    parts.append("## 功能概述\n")
    parts.append(existing_func or "（待根据SQL逻辑补充）")
    parts.append("")

    label = "依赖关系（监管集市表）" if tables else "依赖关系"
    parts.append(f"## {label}\n")
    if tables:
        parts.append("| 表名 | 中文名 | 用途 |")
        parts.append("|------|--------|------|")
        for t in tables:
            cn = TABLE_MAP.get(t, t)
            usage = existing_usage.get(t, existing_usage.get(f"SMTMODS.{t}", ""))
            parts.append(f"| {t} | {cn} | {usage} |")
    else:
        parts.append("（无直接引用SMTMODS表）")
    parts.append("")

    parts.append("## 关键逻辑\n")
    parts.append(existing_logic or "（待根据SQL逻辑补充）")
    parts.append("")

    parts.append("## 修改历史\n")
    parts.append(existing_history or f"- {history_text}" if history_text else "- 无明确变更记录")
    parts.append("")

    write_utf8(ent_path, "\n".join(parts))


# ===================================================
# 主流程
# ===================================================

if __name__ == "__main__":
    total_ok = total_skip = 0
    for d in DIRS:
        src_dir, ent_dir, ext, biz = d["src"], d["ent"], d["ext"], d["biz"]
        if not os.path.exists(src_dir):
            print(f"[SKIP] 目录不存在: {src_dir}")
            continue
        files = sorted([f for f in os.listdir(src_dir) if f.endswith(ext)])
        print(f"\n=== {biz} ({len(files)} files) ===")
        for fname in files:
            src_path = os.path.join(src_dir, fname)
            ent_path = os.path.join(ent_dir, fname.replace(ext, ".md"))
            result = process_prc(src_path, ent_path) if ext == ".prc" else process_sql(src_path, ent_path, biz)
            print(f"  {result}")
            total_ok += result.startswith("[OK]")
            total_skip += not result.startswith("[OK]")
    print(f"\n完成：成功 {total_ok}，跳过 {total_skip}")
