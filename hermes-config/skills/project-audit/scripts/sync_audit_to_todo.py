#!/usr/bin/env python3
"""
审计结果同步到待优化清单脚本

用法:
  python3 sync_audit_to_todo.py --from-file <审计发现JSON文件>

功能:
  读取审计发现JSON → 分类映射 → 去重 → 写入待优化清单.md

注意: section ID 必须与待优化清单.md 中的 ### 1.1 / ### 2.3 等标题匹配。
   脚本从标题行提取的 section ID 是 "一.1"、"二.3" 等形式，
   不包含第三层小数点 "一.1.1"。RULES 中的 section 值必须与此一致。
"""

import re
import os
import sys
import json
from pathlib import Path
from collections import defaultdict

# ─── 分类映射规则 ───────────────────────────────────────────
# section IDs 必须与待优化清单.md 中的 ### 1.1 / ### 2.3 等标题匹配
# 脚本从标题行提取的 section ID 是 "一.1"、"二.3" 等形式

RULES = [
    # ===== 项目管理层面 =====
    (["Part2 占位符"], "一.1",
     '从对应 .prc/源码中提取 WHERE 筛选条件和 DECODE/CASE WHEN 映射规则，补充到第二部分'),

    (["两缺"], "一.1",
     '确认该报表源码是否应被收录到仓库中。若是，收录后补充 SMTMODS 表和源码引用；若否，保持"未收录"标注即可'),

    (["第二部分# 第二部分", "第1部分# 第二部分"], "一.1",
     '修正标题拼接错误——将"# 第二部分# 第二部分："替换为"# 第二部分："'),

    (["Part1 占位符", "原文占位符"], "一.1",
     '从发文原文文件中提取表级业务说明和字段清单摘要，补充到第一部分'),

    (["内容单薄"], "一.1",
     '深入阅读对应 .prc 源码，提取实质性业务筛选条件和 DECODE/CASE WHEN 映射逻辑'),

    (["字段数=0"], "一.1",
     '从原文章中提取字段清单，补充字段总数和关键字段说明'),

    (["无源码解析"], "一.2",
     '创建对应的源码解析文件，添加头部注释（程序名、用途、输出表）和关键 SQL 段落的业务含义标注'),

    (["index.md 缺失", "索引不完整", "未在index.md中"], "一.3",
     '在 index.md 中补充该报表条目，按业务域分组并添加实体文件链接'),

    (["AGENTS.md", "查询流程规则"], "一.3",
     '更新 AGENTS.md 对应规则描述，确保查询流程清晰完整'),

    (["文件编码"], "一.4",
     '统一文件编码为 UTF-8，去除 GBK 编码文件'),

    (["标题重复", "格式错误", "markdown渲染"], "一.1",
     '修正文件格式错误，确保 markdown 正确渲染'),

    # ===== 系统代码层面 =====
    (["缺集市表", "不引用 SMTMODS", "未引用 SMTMODS"], "二.3",
     '调查该程序的数据源链路：若数据最终来自 SMTMODS 但经过中间表，标注为"间接引用"；若完全不经过 SMTMODS，评估改造成本'),

    (["违规", "完全不经", "数据源违规"], "二.3",
     '改造为从 SMTMODS 视图/表取数，确保数据源合规'),

    (["别名不匹配", "temp 表列名", "列名与引用", "alias"], "二.1",
     '修正 temp 表列名定义，确保 SELECT 列与后续引用别名一致'),

    (["重复代码", "冗余逻辑", "公共逻辑未提取"], "二.1",
     '提取公共逻辑为函数/视图，消除重复代码'),

    (["性能", "索引缺失", "全表扫描", "效率"], "二.2",
     '分析执行计划，添加缺失索引或优化 JOIN 顺序'),

    (["推荐优化"], "二.4",
     '参考具体建议实施优化'),
]


def load_existing_todos(todo_file):
    """读取现有的待优化清单，返回所有已有问题描述的集合"""
    if not todo_file.exists():
        return set()

    content = todo_file.read_text(encoding="utf-8")
    existing = set()

    for line in content.split("\n"):
        line = line.strip()
        if line.startswith("|") and not line.startswith("| #") and not line.startswith("|---"):
            cols = [c.strip() for c in line.split("|")]
            if len(cols) >= 3:
                existing.add(cols[2])

    return existing


def classify_issue(desc_text):
    """根据问题描述分类返回 (section_id, solution_template)"""
    for keywords, section, solution in RULES:
        for kw in keywords:
            if kw.lower() in desc_text.lower():
                return section, solution
    return "一.4", '需人工评估具体优化方案'


def build_todo_entry(num, description, files, solution, priority):
    return f"| {num} | {description} | {files} | {solution} | {priority} | 🔴 待处理 | 审计自动 |"


def parse_section_structure(lines):
    """
    解析文件结构，返回:
      section_counts: {section_id: 已有最大编号}
      section_insert_pos: {section_id: 插入位置的行索引}
    """
    current_section = None
    section_counts = {}
    section_insert_pos = {}

    for i, line in enumerate(lines):
        m1 = re.match(r'^### 1\.(\d) (.+)', line)
        m2 = re.match(r'^### 2\.(\d) (.+)', line)
        if m1:
            current_section = f"一.{m1.group(1)}"
            section_insert_pos[current_section] = -1
            section_counts.setdefault(current_section, 0)
        elif m2:
            current_section = f"二.{m2.group(1)}"
            section_insert_pos[current_section] = -1
            section_counts.setdefault(current_section, 0)

        # 表格分隔行后就是数据插入区
        if current_section and "|---" in line:
            section_insert_pos[current_section] = i + 1

        # 统计已有记录数
        if current_section:
            m = re.match(r'^\|\s*(\d+)\s*\|', line)
            if m:
                num = int(m.group(1))
                if section_counts.get(current_section, 0) < num:
                    section_counts[current_section] = num

    return section_counts, section_insert_pos


def sync_audit_findings_to_file(findings_json_path, todo_file_path):
    """从JSON文件读取审计发现并同步到待优化清单"""
    with open(findings_json_path, "r", encoding="utf-8") as f:
        findings = json.load(f)

    if not findings:
        print("没有审计发现需要同步")
        return

    todo_file = Path(todo_file_path)
    existing = load_existing_todos(todo_file)
    print(f"现有待优化项: {len(existing)} 条")

    content = todo_file.read_text(encoding="utf-8")
    lines = content.split("\n")

    section_counts, section_insert_pos = parse_section_structure(lines)
    print(f"各节现有记录数: {dict(section_counts)}")

    new_entries = []
    for finding in findings:
        desc = finding.get("description", "").strip()
        files = finding.get("files", "").strip()
        priority = finding.get("priority", "P2")
        if not desc:
            continue

        if desc in existing:
            print(f"  ⏭️ 跳过重复: {desc[:60]}...")
            continue

        section, solution = classify_issue(desc)
        num = section_counts.get(section, 0) + 1
        section_counts[section] = num

        entry = build_todo_entry(num, desc, files, solution, priority)
        insert_pos = section_insert_pos.get(section, -1)
        new_entries.append((section, entry, insert_pos, num))
        print(f"  ✅ {section} #{num}: {desc[:60]}...")
        existing.add(desc)

    if not new_entries:
        print("没有新待优化项需要写入")
        return

    # 倒序插入（保持行号不变）
    new_entries.sort(key=lambda x: -x[2])

    for section, entry, insert_pos, num in new_entries:
        if insert_pos < 0:
            print(f"  ⚠️ 找不到 {section} 的插入位置，如果表格为空请在 '|---|' 下面的空数据行处手动插入")
            continue
        lines.insert(insert_pos, entry)

    todo_file.write_text("\n".join(lines), encoding="utf-8")
    print(f"\n✅ 成功写入 {len(new_entries)} 条待优化项到 {todo_file}")


def main():
    DEFAULT_TODO = "/mnt/e/workspace/金融基础数据报送系统/待优化事项/待优化清单.md"

    if len(sys.argv) == 3 and sys.argv[1] == "--from-file":
        sync_audit_findings_to_file(sys.argv[2], DEFAULT_TODO)
    elif len(sys.argv) == 5 and sys.argv[1] == "--from-file" and sys.argv[3] == "--todo":
        sync_audit_findings_to_file(sys.argv[2], sys.argv[4])
    else:
        print("用法:")
        print("  python3 sync_audit_to_todo.py --from-file <审计发现JSON文件>")
        print("  python3 sync_audit_to_todo.py --from-file <JSON文件> --todo <待优化清单路径>")
        print("")
        print("JSON格式:")
        print('[  {')
        print('    "description": "问题描述",')
        print('    "files": "涉及文件路径",')
        print('    "priority": "P1/P2/P3"')
        print('  }')
        print(']')


if __name__ == "__main__":
    main()
