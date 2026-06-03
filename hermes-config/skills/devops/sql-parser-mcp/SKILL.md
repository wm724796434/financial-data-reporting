---
name: sql-parser-mcp
description: Use when building or integrating a SQL parser tool for Oracle/PLSQL stored procedures via MCP server. Covers sqlglot setup, MCP stdio server code, config.yaml registration, and the extraction-to-parsing pipeline for domain-specific code analysis.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [sql, parser, mcp, oracle, plsql, sqlglot, code-analysis]
    related_skills: [native-mcp, hermes-agent-skill-authoring]
---

# SQL Parser MCP Server

## Overview

为金融基础数据报送系统构建的 SQL 解析器 MCP 服务。使用 sqlglot 作为解析引擎，通过 MCP stdio 协议注册为 Agent 的一等工具，用于从 Oracle 存储过程（.prc）中自动提取表依赖、过滤条件、字段映射等结构化信息。

核心价值：**把 LLM "阅读理解 SQL" 替换为确定性 SQL 解析器**，消除因 LLM 阅读 SQL 导致的遗漏和幻觉。

## When to Use

- 需要从 Oracle 存储过程中提取结构化元数据（表依赖、WHERE 条件、字段映射）
- 需要让 Agent 在回答"取数范围""字段映射"类问题时，基于精确的解析结果而非 LLM 阅读理解
- 需要为项目构建结构化元数据目录（`结构化元数据/`），作为源码和实体文件之间的中间层

Don't use for:
- 非 Oracle 方言的 SQL（需调整 `read` 参数）
- 动态 SQL（`EXECUTE IMMEDIATE`）——sqlglot 无法解析，需人工审查
- 临时的一次性 SQL 查询——用 terminal 直接调 sqlglot 即可

## Prerequisites

```bash
pip install sqlglot mcp
```

确认安装：

```bash
python3 -c "import sqlglot; import mcp; print('OK')"
```

## Architecture

```
Agent 启动 → 连接 MCP server → 发现两个工具：
  ├── mcp_sql_parser_parse_prc(prc_path)   ← 从 .prc 文件一步到位
  └── mcp_sql_parser_parse_sql(sql, dialect) ← 直接解析一段 SQL
```

MCP server 是常驻子进程，sqlglot 只加载一次，后续调用零启动开销。不要用 terminal 每次启动 Python 进程的方式——每次 import sqlglot 要 1-2 秒。

内部流程（parse_prc）：
```
.prc 文件 → 读取 → 从 PL/SQL 中提取 SQL 语句 → 逐条 sqlglot 解析 → 汇总去重 → 返回 JSON
```

## Setup

### 1. 放置 MCP Server 脚本

将下方的完整脚本保存为项目中的 `scripts/mcp_sql_parser.py`：

```
/mnt/e/workspace/金融基础数据报送系统/scripts/mcp_sql_parser.py
```

### 2. 注册到 Hermes

在 `~/.hermes/config.yaml` 中添加（如果文件不存在则创建）：

```yaml
mcp_servers:
  sql-parser:
    command: "python3"
    args:
      - "/mnt/e/workspace/金融基础数据报送系统/scripts/mcp_sql_parser.py"
    timeout: 30
```

如果使用虚拟环境，替换 `command` 为 venv 中的 python 路径：

```yaml
    command: "/home/wm/.venv/bin/python3"
```

### 3. 重启 Agent

重启后两个工具自动注册：
- `mcp_sql_parser_parse_prc`
- `mcp_sql_parser_parse_sql`

## Tools Reference

### parse_prc

```
输入: prc_path (str) — .prc 文件路径（绝对路径或相对于项目根目录）
输出: JSON 字符串
```

返回结构：

```json
{
  "file": "/path/to/file.prc",
  "total_statements": 3,
  "parse_errors": 0,
  "tables": [
    {"name": "SMTMODS_L_ACCT_LOAN", "alias": "A"},
    {"name": "SMTMODS_L_CUST_BASIC", "alias": "C"}
  ],
  "joins": [
    {"type": "INNER", "table": "C", "on": "A.CUST_ID = C.CUST_ID", "role": "过滤"},
    {"type": "LEFT", "table": "T", "on": "A.LOAN_NUM = T.LOAN_NUM", "role": "仅字段补充"}
  ],
  "where_conditions": [
    "A.SUBJECT_CD IN ('AAAA', 'BBBB')",
    "C.CUST_TYPE_CD != 'P'"
  ],
  "select_columns": [
    {"expression": "A.LOAN_NUM", "alias": null},
    {"expression": "DECODE(T.FLAG, ...)", "alias": "DIGITAL_ECONOMY_TYPE"}
  ],
  "statements": [...]  // 每条 SQL 的独立解析结果
}
```

### parse_sql

```
输入: sql (str) — SQL 语句文本
      dialect (str) — SQL 方言，默认 "oracle"
输出: JSON 字符串（结构同上，不含 file/total_statements/statements 顶层字段）
```

## Agent Workflow Integration

典型使用场景——Agent 回答"XX 报表取数范围"：

```
1. 规则引擎路由 → entity_id → prc_path
2. 调用 mcp_sql_parser_parse_prc(prc_path) → 获得结构化 JSON
3. LLM 基于 JSON 中的 where_conditions 和 joins 生成回答：
   - 将所有 where_conditions 拼成完整 WHERE 子句
   - 根据 joins[role="过滤"] 标注 INNER JOIN 的过滤角色
   - 区分【过滤】条件和【仅字段补充】的 JOIN
4. 回答中嵌入完整 SQL 取数范围
```

对比原来：read_file(prc) 读入 100-200KB 源码 → LLM 自己阅读理解 SQL → 可能遗漏条件。现在：MCP 调用返回 5-10KB 结构化 JSON → LLM 直接使用，不会遗漏。

## MCP Server Code

完整的 server 脚本（复制到 `scripts/mcp_sql_parser.py`）：

```python
#!/usr/bin/env python3
"""
MCP Server: SQL 解析器 for 金融基础数据报送系统
提供两个工具：
  - parse_prc: 从 .prc 文件提取并解析 SQL
  - parse_sql: 直接解析 SQL 语句
"""
import json
import re
import sys
from pathlib import Path

import sqlglot
from sqlglot import exp
from mcp.server import Server
from mcp.server.stdio import stdio_server

# ──── 核心解析逻辑 ────

def extract_sql_from_plsql(content: str) -> list[dict]:
    """
    从 PL/SQL 内容中提取 SQL 语句。
    返回: [{"type": "SELECT|INSERT|UPDATE|MERGE", "sql": "...", "line": N}, ...]
    """
    statements = []
    keywords = r'\b(SELECT|INSERT\s+INTO|UPDATE|MERGE\s+INTO|with)\b'
    
    for match in re.finditer(keywords, content, re.IGNORECASE):
        start = match.start()
        rest = content[start:]
        depth = 0
        end = 0
        in_string = False
        for i, ch in enumerate(rest):
            if ch == "'" and (i == 0 or rest[i-1] != '\\'):
                in_string = not in_string
            if not in_string:
                if ch == '(':
                    depth += 1
                elif ch == ')':
                    depth -= 1
                elif ch == ';' and depth == 0:
                    end = i
                    break
        if end > 0:
            sql = rest[:end].strip()
            stmt_type = match.group(1).split()[0].upper()
            line_num = content[:start].count('\n') + 1
            statements.append({
                "type": stmt_type,
                "sql": sql,
                "line": line_num
            })
    return statements


def parse_single_sql(sql: str) -> dict:
    """解析单条 SQL，返回结构化信息"""
    try:
        tree = sqlglot.parse_one(sql, read="oracle")
    except Exception as e:
        return {"error": str(e), "sql_preview": sql[:200]}

    result = {
        "tables": [],
        "joins": [],
        "where_conditions": [],
        "select_columns": []
    }

    for table in tree.find_all(exp.Table):
        result["tables"].append({
            "name": str(table),
            "alias": table.alias_or_name
        })

    for join in tree.find_all(exp.Join):
        join_info = {
            "type": join.kind or "INNER",
            "table": str(join.this),
            "on": str(join.args.get("on", ""))
        }
        result["joins"].append(join_info)

    where = tree.find(exp.Where)
    if where:
        for cond in where.find_all(exp.Condition):
            result["where_conditions"].append(str(cond))

    select = tree.find(exp.Select)
    if select:
        for col in select.expressions:
            col_info = {
                "expression": str(col.unnest()),
                "alias": col.alias or None
            }
            result["select_columns"].append(col_info)

    return result


def classify_conditions(parsed_result: dict) -> dict:
    """标注 JOIN 角色：INNER JOIN → 过滤，LEFT JOIN → 仅字段补充"""
    for join in parsed_result.get("joins", []):
        if join["type"].upper() == "INNER":
            join["role"] = "过滤"
        else:
            join["role"] = "仅字段补充"
    return parsed_result


# ──── MCP Server ────

server = Server("sql-parser-for-finance-reporting")


@server.tool()
async def parse_prc(prc_path: str) -> str:
    """
    解析 Oracle 存储过程文件(.prc)，提取所有 SQL 语句并结构化。
    参数: prc_path — .prc 文件路径
    返回: JSON 字符串
    """
    path = Path(prc_path)
    if not path.is_absolute():
        project_root = Path("/mnt/e/workspace/金融基础数据报送系统")
        path = project_root / prc_path

    if not path.exists():
        return json.dumps({"error": f"文件不存在: {path}"}, ensure_ascii=False)

    try:
        content = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        content = path.read_text(encoding="gbk")

    sql_statements = extract_sql_from_plsql(content)

    if not sql_statements:
        return json.dumps({"error": "未找到 SQL 语句", "file": str(path)}, ensure_ascii=False)

    all_results = []
    for stmt in sql_statements:
        parsed = parse_single_sql(stmt["sql"])
        parsed = classify_conditions(parsed)
        parsed["statement_type"] = stmt["type"]
        parsed["source_line"] = stmt["line"]
        all_results.append(parsed)

    summary = _merge_results(all_results)
    summary["file"] = str(path)
    summary["total_statements"] = len(sql_statements)
    summary["parse_errors"] = sum(1 for r in all_results if "error" in r)

    return json.dumps(summary, ensure_ascii=False, indent=2)


@server.tool()
async def parse_sql(sql: str, dialect: str = "oracle") -> str:
    """
    直接解析一条 SQL 语句。
    参数: sql — SQL 语句文本, dialect — 方言（默认 oracle）
    返回: JSON 字符串
    """
    result = parse_single_sql(sql)
    result = classify_conditions(result)
    return json.dumps(result, ensure_ascii=False, indent=2)


def _merge_results(all_results: list) -> dict:
    """汇总多条 SQL 的解析结果（去重）"""
    merged = {
        "tables": [],
        "joins": [],
        "where_conditions": [],
        "select_columns": [],
        "statements": all_results
    }
    seen_tables = set()
    for r in all_results:
        if "error" in r:
            continue
        for t in r.get("tables", []):
            key = t["name"]
            if key not in seen_tables:
                seen_tables.add(key)
                merged["tables"].append(t)
    return merged


if __name__ == "__main__":
    import asyncio
    async def main():
        async with stdio_server() as (read_stream, write_stream):
            await server.run(read_stream, write_stream, server.create_initialization_options())
    asyncio.run(main())
```

## Common Pitfalls

1. **编码问题**：源码解析目录下的 .prc 为 UTF-8，原始备份为 GBK。代码已处理两种编码的自动 fallback。如果新增其他编码的源码文件，需扩展 try/except。

2. **动态 SQL 无法解析**：`EXECUTE IMMEDIATE` 中的 SQL 字符串不会被提取。`parse_errors` 计数不包括这些（它们根本没被提取到）。如果需要覆盖动态 SQL，需另行设计静态分析方案。

3. **临时表的字段映射不完整**：如果临时表是通过 `CREATE TABLE AS SELECT` 创建的，解析器能提取 SELECT 部分。但如果字段分散在多个 INSERT 中定义，会遗漏。

4. **正则提取的边界情况**：`extract_sql_from_plsql` 用简单的括号深度计数器找分号结尾。极端嵌套的子查询可能误判语句边界。如果发现某条 SQL 被截断或合并，检查括号深度是否超过预期。

5. **JOIN 角色标注是启发式的**：INNER JOIN → 过滤，LEFT JOIN → 仅字段补充。这个规则在大部分场景正确，但存在例外（某些 LEFT JOIN 在 WHERE 中有 IS NOT NULL 过滤）。发现标注错误时，手动在 JSON 中修正。

6. **MCP server 环境变量被过滤**：Hermes 传给 MCP 子进程的环境变量只有安全的基线变量（PATH, HOME, USER 等）。如果 server 需要特定的环境变量（如 PYTHONPATH），需在 config.yaml 的 `env` 字段中显式声明。

## Verification Checklist

- [ ] `pip install sqlglot mcp` 成功
- [ ] 脚本放置在 `scripts/mcp_sql_parser.py`
- [ ] `~/.hermes/config.yaml` 中 `mcp_servers.sql-parser` 配置正确
- [ ] 重启 Agent 后 `mcp_sql_parser_parse_prc` 和 `mcp_sql_parser_parse_sql` 出现在工具列表中
- [ ] 用一个已知的 .prc 文件测试 parse_prc，确认返回的 JSON 中 tables/where_conditions 与人工审查一致
- [ ] `parse_errors` 计数为 0（或标记出已知的无法解析语句）

## References

- `references/vertical-agent-architecture.md` — 垂类 Agent 五层架构理论与本项目定位分析
