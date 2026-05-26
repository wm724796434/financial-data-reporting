#!/usr/bin/env python3
"""
批量处理有源码的"Part2内容单薄"实体文件。
对每个有源码的文件：读取源码关键SQL → 提取WHERE条件+DECODE映射 → 补充到实体文件Part2
"""

import re
import os
import sys
from pathlib import Path

PROJECT = Path("/mnt/e/workspace/金融基础数据报送系统")
SRC = PROJECT / "源码解析/加工层存储"
ENTITIES = PROJECT / "实体"

# ─── 文件映射 ───
FILES = [
    # (实体文件名, 源码文件名)
    ("个人客户基础信息_JS_102_GRKHXX.md", "bsp_sp_js_102_grkhxx.prc", True),  # 已处理
    ("个人贷款发生额信息_JS_201_GRDKFS.md", "bsp_sp_js_201_grdkfs.prc", False),
    ("债券投资发生额信息_JS_203_ZQTZFS.md", "bsp_sp_js_203_zqtzfs.prc", False),
    ("再贴现发生额信息_JS_205_ZTXFS.md", "bsp_sp_js_205_ztxfs.prc", False),
    ("单位贷款发生额信息_JS_201_DWDKFS.md", "bsp_sp_js_201_dwdkfs.prc", False),
    ("单位贷款置换旧债发生额信息_JS_201_ZHJZFS.md", "bsp_sp_js_201_zhjzfs.prc", False),
    ("同业借贷发生额信息_JS_201_TYJDFS.md", "bsp_sp_js_201_tyjdfs.prc", False),
    ("同业存款发生额信息_JS_202_TYCKFS.md", "bsp_sp_js_202_tyckfs.prc", False),
    ("同业客户基础信息_JS_102_TYKHXX.md", "bsp_sp_js_102_tykhxx.prc", False),
    ("委托贷款发生额信息_JS_201_WTDKFS.md", "bsp_sp_js_201_wtdkfs.prc", False),
    ("存贷款客户核对_JS_201_HDACLHLDK.md", "bsp_sp_js_201_hdaclhldk.prc", False),
    ("存量个人存款信息_JS_202_CLGRCK.md", "bsp_sp_js_202_clgrck.prc", False),
    ("存量个人贷款信息_JS_201_CLGRDK.md", "bsp_sp_js_201_clgrdk.prc", False),
    ("存量再贴现信息_JS_205_CLZTX.md", "bsp_sp_js_205_clztx.prc", False),
    ("存量同业借贷信息_JS_201_CLTYJD.md", "bsp_sp_js_201_cltyjd.prc", False),
    ("存量同业存款信息_JS_202_CLTYCK.md", "bsp_sp_js_202_cltyck.prc", False),
    ("存量票据融资信息_JS_205_CLPJRZ.md", "bsp_sp_js_205_clpjrz.prc", False),
    ("存量银行承兑汇票信息_JS_205_CLYHCD.md", "bsp_sp_js_205_clyhcd.prc", False),
    ("存量非同业单位存款信息_JS_202_FTYDWC.md", "bsp_sp_js_202_ftydwc.prc", False),
    ("票据融资发生额信息_JS_205_PJRZFS.md", "bsp_sp_js_205_pjrzfs.prc", False),
    ("金融机构（分支机构）基础信息_JS_101_JRJGFZ.md", "bsp_sp_js_101_jrjgfz.prc", False),
    ("银行承兑汇票发生额信息_JS_205_YHCDFS.md", "bsp_sp_js_205_yhcdfs.prc", False),
    ("非同业单位存款发生额信息_JS_202_DWCKFS.md", "bsp_sp_js_202_dwckfs.prc", False),
]


def read_file(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def write_file(path, content):
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)


def extract_sql_info(src_path):
    """从源码文件中提取关键SQL信息"""
    content = read_file(src_path)
    lines = content.split("\n")
    
    info = {
        "purpose": "",
        "domain": "",
        "smtmods_tables": [],
        "where_conditions": [],
        "decode_cases": [],
        "from_tables": [],
    }
    
    for line in lines:
        # 程序用途
        if "-- 用途:" in line:
            info["purpose"] = line.split("-- 用途:")[1].strip()
        if "-- 业务域:" in line:
            info["domain"] = line.split("-- 业务域:")[1].strip()
        
        # SMTMODS 表
        if "FROM SMTMODS." in line.upper() or "JOIN SMTMODS." in line.upper():
            for m in re.finditer(r'SMTMODS\.\w+', line, re.IGNORECASE):
                tbl = m.group(0)
                if tbl not in info["smtmods_tables"]:
                    info["smtmods_tables"].append(tbl)
        
        # FROM 中的裸表
        m = re.search(r'FROM\s+(\w+)', line)
        if m:
            tbl = m.group(1)
            if tbl != "SMTMODS" and tbl not in info["from_tables"]:
                info["from_tables"].append(tbl)
        
        # WHERE 条件
        if re.search(r'WHERE\s+.*=', line, re.IGNORECASE):
            info["where_conditions"].append(line.strip())
        if re.search(r'AND\s+.*(?:=|IN|LIKE|NOT|IS|BETWEEN)', line, re.IGNORECASE):
            if "DATA_DATE" in line or "CUST_TYPE" in line or "BALANCE" in line or "STATUS" in line or "FLAG" in line or "AMT" in line or "TYPE" in line:
                info["where_conditions"].append(line.strip())
        
        # DECODE / CASE WHEN
        if "DECODE(" in line.upper() or "CASE WHEN" in line.upper():
            info["decode_cases"].append(line.strip())
    
    return info


def build_filter_section(info):
    """构建业务筛选条件章节"""
    section = "**程序用途**：" + info["purpose"] + "\n\n"
    
    if info["smtmods_tables"]:
        section += "**SMTMODS 数据源表**：\n"
        for t in info["smtmods_tables"]:
            section += f"- `{t}`\n"
        section += "\n"
    
    if info["where_conditions"]:
        # 提取核心筛选条件
        date_conds = [l for l in info["where_conditions"] if "DATA_DATE" in l or "CJRQ" in l or "data_date" in l.lower()]
        biz_conds = [l for l in info["where_conditions"] if "DATA_DATE" not in l and "CJRQ" not in l and "data_date" not in l.lower()]
        
        if date_conds:
            section += "**时间筛选**：\n"
            section += "```sql\n"
            section += f"WHERE T.DATA_DATE = IS_DATE\n"
            section += "```\n\n"
        
        if biz_conds:
            section += "**业务筛选条件**：\n"
            section += "```sql\n"
            for c in biz_conds[:8]:
                section += c + "\n"
            section += "```\n\n"
    
    return section


def build_special_section(info):
    """构建特殊处理规则章节"""
    cases = info["decode_cases"]
    if not cases or len(cases) < 3:
        return None
    
    lines = []
    lines.append("| 字段 | 规则 | 说明 |")
    lines.append("|------|------|------|")
    
    for c in cases[:10]:
        # 尝试提取有意义的规则描述
        c_clean = c.strip()
        # 移除开头的逗号、AND等
        c_clean = re.sub(r'^[,AND\s]+', '', c_clean)
        
        # 从注释提取说明
        comment = ""
        if "--" in c_clean:
            parts = c_clean.split("--")
            c_clean = parts[0].strip()
            comment = parts[1].strip()
        
        if len(c_clean) > 10 and "CASE" in c_clean.upper() or "DECODE" in c_clean.upper():
            desc = comment if comment else "字段映射规则"
            # 截取前50个字符作为规则展示
            rule_short = c_clean[:60] + "..." if len(c_clean) > 60 else c_clean
            lines.append(f"| `...` | `{rule_short}` | {desc} |")
    
    if len(lines) > 1:
        return "\n".join(lines)
    return None


def process_file(entity_name, src_name, is_done):
    """处理单个文件"""
    log = []
    log.append(f"\n{'='*60}")
    log.append(f"📄 {entity_name}")
    log.append(f"{'='*60}")
    
    if is_done:
        log.append("  ⏭️ 跳过（示范文件已处理）")
        return "\n".join(log)
    
    src_path = SRC / src_name
    ent_path = ENTITIES / entity_name
    
    if not src_path.exists():
        log.append(f"  ❌ 源码不存在: {src_path}")
        return "\n".join(log)
    if not ent_path.exists():
        log.append(f"  ❌ 实体文件不存在: {ent_path}")
        return "\n".join(log)
    
    # 读取源码和实体文件
    info = extract_sql_info(src_path)
    ent_content = read_file(ent_path)
    
    # 判断是否已经有实质性内容
    has_where = "WHERE" in ent_content and ("DATA_DATE" in ent_content or "SMTMODS." in ent_content.split("WHERE")[-1][:200])
    has_decode = "CASE WHEN" in ent_content or "DECODE" in ent_content
    
    if has_where or has_decode:
        log.append(f"  ⏭️ 跳过：已有较完整业务规则")
        return "\n".join(log)
    
    # 构建补充内容
    filter_section = build_filter_section(info)
    special_section = build_special_section(info)
    
    log.append(f"  程序: {info['purpose'][:60]}")
    log.append(f"  所属: {info['domain']}")
    log.append(f"  SMTMODS表: {len(info['smtmods_tables'])}个")
    log.append(f"  WHERE条件: {len(info['where_conditions'])}条")
    log.append(f"  DECODE/CASE: {len(info['decode_cases'])}处")
    
    # 更新实体文件
    old_filter = "## 4. 业务筛选条件\n\n详细取数逻辑见源码解析文件。"
    old_special = "## 5. 特殊处理规则\n\n无特殊处理。"
    new_special = f"## 5. 特殊处理规则\n\n{special_section}" if special_section else "## 5. 特殊处理规则\n\n（无特殊处理规则）"
    
    if "详细取数逻辑见源码解析文件" in ent_content:
        ent_content = ent_content.replace(old_filter, f"## 4. 业务筛选条件\n\n{filter_section}")
        if "无特殊处理" in ent_content and special_section:
            ent_content = ent_content.replace(old_special, new_special)
        write_file(ent_path, ent_content)
        log.append(f"  ✅ 已更新Part2")
    else:
        log.append(f"  ⏭️ 跳过：Part2已有自定内容")
    
    return "\n".join(log)


def main():
    log_all = ["# 批量处理Part2内容单薄文件 - 执行日志", f"时间: {__import__('datetime').datetime.now()}", ""]
    
    success = 0
    skipped = 0
    failed = 0
    
    for entity_name, src_name, is_done in FILES:
        try:
            result = process_file(entity_name, src_name, is_done)
            log_all.append(result)
            if "✅" in result:
                success += 1
            elif "⏭️" in result:
                skipped += 1
            elif "❌" in result:
                failed += 1
        except Exception as e:
            log_all.append(f"  ❌ 异常: {e}")
            failed += 1
    
    # 汇总
    log_all.append(f"\n{'='*60}")
    log_all.append(f"✅ 成功更新: {success} | ⏭️ 跳过: {skipped} | ❌ 失败: {failed}")
    
    result = "\n".join(log_all)
    
    # 写日志
    log_path = PROJECT / "scripts/batch_update_log.txt"
    with open(log_path, "w", encoding="utf-8") as f:
        f.write(result)
    
    print(result)


if __name__ == "__main__":
    main()
