#!/usr/bin/env python3
"""
MCP Server: SQL 解析器 for 金融基础数据报送系统

提供两个工具：
  - parse_prc: 从 Oracle 存储过程文件 (.prc) 提取并解析 SQL
  - parse_sql: 直接解析一条 SQL 语句

依赖: sqlglot, mcp
安装: uv pip install sqlglot mcp
"""
import json
import re
import asyncio
from pathlib import Path

import sqlglot
from sqlglot import exp
from mcp.server import Server
from mcp.server.stdio import stdio_server


# ═══════════════════════════════════════════════════════════════
#  核心解析逻辑
# ═══════════════════════════════════════════════════════════════

def strip_sql_comments(sql: str) -> str:
    """
    去掉 SQL 中的 -- 行注释和 /* */ 块注释。
    正确处理字符串字面量内的 -- 和 /*（不误删）。
    """
    result = []
    i = 0
    n = len(sql)
    while i < n:
        ch = sql[i]
        next_ch = sql[i + 1] if i + 1 < n else ""

        # -- 行注释
        if ch == "-" and next_ch == "-":
            i += 2
            while i < n and sql[i] not in ("\n", "\r"):
                i += 1
            continue

        # /* 块注释 */
        if ch == "/" and next_ch == "*":
            i += 2
            while i < n - 1 and not (sql[i] == "*" and sql[i + 1] == "/"):
                i += 1
            i += 2  # 跳过 */
            continue

        # 字符串字面量（保留内容，不解析内部）
        if ch == "'":
            result.append(ch)
            i += 1
            while i < n:
                result.append(sql[i])
                if sql[i] == "'":
                    if i + 1 < n and sql[i + 1] == "'":
                        # 转义的单引号 ''
                        result.append(sql[i + 1])
                        i += 2
                        continue
                    break
                i += 1
            i += 1
            continue

        result.append(ch)
        i += 1
    return "".join(result)


def extract_sql_from_plsql(content: str) -> list[dict]:
    """
    从 PL/SQL 存储过程源码中提取 SQL 语句。

    识别 INSERT INTO / SELECT / UPDATE / DELETE FROM / MERGE INTO / WITH
    开头的完整 SQL 语句（到分号结束），跳过被 -- 注释掉的代码。

    处理括号嵌套、字符串内的分号、块注释。
    """
    statements = []
    n = len(content)

    kw_pattern = re.compile(
        r"\b(SELECT|INSERT\s+INTO|UPDATE|DELETE\s+FROM|MERGE\s+INTO|WITH)\b",
        re.IGNORECASE,
    )

    i = 0
    while i < n:
        remaining = content[i:]
        match = kw_pattern.search(remaining)
        if not match:
            break

        match_pos = i + match.start()

        # ── 检查是否被 -- 注释掉了 ──
        line_start = content.rfind("\n", 0, match_pos)
        if line_start == -1:
            line_start = 0
        else:
            line_start += 1
        line_before = content[line_start:match_pos]
        if "--" in line_before:
            i = match_pos + 1
            continue

        stmt_type = match.group(1).split()[0].upper()

        # ── 状态机扫描：找匹配的分号 ──
        depth = 0
        in_string = False
        in_line_comment = False
        in_block_comment = False
        j = match_pos

        while j < n:
            ch = content[j]
            nc = content[j + 1] if j + 1 < n else ""

            # 块注释 /*
            if not in_string and not in_line_comment and ch == "/" and nc == "*":
                in_block_comment = True
                j += 2
                continue
            if in_block_comment and ch == "*" and nc == "/":
                in_block_comment = False
                j += 2
                continue
            if in_block_comment:
                j += 1
                continue

            # 行注释 --
            if not in_string and not in_block_comment and ch == "-" and nc == "-":
                in_line_comment = True
                j += 2
                continue
            if in_line_comment and ch in ("\n", "\r"):
                in_line_comment = False
                j += 1
                continue
            if in_line_comment:
                j += 1
                continue

            # 字符串
            if ch == "'" and not in_block_comment:
                if in_string:
                    if nc == "'":
                        j += 2
                        continue
                    in_string = False
                else:
                    in_string = True

            # 括号和分号（仅在非字符串、非注释中）
            if not in_string and not in_block_comment:
                if ch == "(":
                    depth += 1
                elif ch == ")":
                    depth -= 1
                elif ch == ";" and depth == 0:
                    sql = content[match_pos:j].strip()
                    line_num = content[:match_pos].count("\n") + 1
                    statements.append(
                        {"type": stmt_type, "sql": sql, "line": line_num}
                    )
                    i = j + 1
                    break
            j += 1
        else:
            i = match_pos + 1

    return statements


def parse_single_sql(sql: str) -> dict:
    """
    解析单条 SQL 语句，返回结构化信息。

    返回:
    {
      "tables": [{"full_name": "SMTMODS.L_ACCT_LOAN", "alias": "A"}, ...],
      "joins": [
        {"type": "INNER", "table": "SMTMODS.L_CUST_C", "alias": "C",
         "on_conditions": ["A.CUST_ID = C.CUST_ID", "C.CUST_TYP <> '3'"],
         "role": "过滤"},
        ...
      ],
      "where_conditions": ["A.SUBJECT_CD IN (...)", ...],
      "select_columns": [
        {"expression": "A.LOAN_NUM", "alias": null},
        ...
      ]
    }
    """
    # 预处理：去注释
    clean_sql = strip_sql_comments(sql)

    try:
        tree = sqlglot.parse_one(clean_sql, read="oracle")
    except Exception as e:
        return {"error": f"SQL 解析失败: {e}", "sql_preview": sql[:200]}

    result = {"tables": [], "joins": [], "where_conditions": [], "select_columns": []}

    # ── 1. 提取表名（含 schema）──
    seen_tables = set()
    for table in tree.find_all(exp.Table):
        full_name = str(table)  # e.g. "SMTMODS.L_ACCT_LOAN" or "L_ACCT_LOAN"
        alias = table.alias_or_name
        key = (full_name, alias)
        if key not in seen_tables:
            seen_tables.add(key)
            result["tables"].append({"full_name": full_name, "alias": alias})

    # ── 2. 提取 JOIN + ON 条件 ──
    for join_node in tree.find_all(exp.Join):
        join_type = join_node.kind or "INNER"
        join_table = str(join_node.this)

        # 提取 JOIN 表的别名
        join_alias = None
        if join_node.this.alias:
            join_alias = join_node.this.alias

        on_conds = []
        on_expr = join_node.args.get("on")
        if on_expr:
            # 拆分 AND 条件
            if isinstance(on_expr, exp.And):
                for part in on_expr.flatten():
                    on_conds.append(str(part))
            else:
                on_conds.append(str(on_expr))

        # 角色标注
        role = "过滤" if join_type.upper() == "INNER" else "仅字段补充"

        result["joins"].append(
            {
                "type": join_type,
                "table": join_table,
                "alias": join_alias,
                "on_conditions": on_conds,
                "role": role,
            }
        )

    # ── 3. 提取 WHERE 条件 ──
    where = tree.find(exp.Where)
    if where:
        cond = where.this
        if isinstance(cond, exp.And):
            for part in cond.flatten():
                result["where_conditions"].append(str(part))
        else:
            result["where_conditions"].append(str(cond))

    # ── 4. 提取 SELECT 字段 ──
    select_node = tree.find(exp.Select)
    if select_node:
        for col in select_node.expressions:
            result["select_columns"].append(
                {
                    "expression": str(col.unnest()),
                    "alias": col.alias or None,
                }
            )

    return result


def merge_results(all_results: list[dict]) -> dict:
    """汇总多条 SQL 解析结果，去重。"""
    merged = {
        "tables": [],
        "joins": [],
        "where_conditions": [],
        "total_columns": 0,
        "statements": [],
    }

    seen_tables = set()
    seen_joins = set()

    for r in all_results:
        # 跳过解析失败的
        if "error" in r:
            merged["statements"].append(r)
            continue

        # 表去重
        for t in r.get("tables", []):
            key = (t["full_name"], t["alias"])
            if key not in seen_tables:
                seen_tables.add(key)
                merged["tables"].append(t)

        # JOIN 去重
        for j in r.get("joins", []):
            key = (j["type"], j["table"], j.get("alias"))
            if key not in seen_joins:
                seen_joins.add(key)
                merged["joins"].append(j)

        # WHERE 条件累积（保留所有，去重）
        for w in r.get("where_conditions", []):
            if w not in merged["where_conditions"]:
                merged["where_conditions"].append(w)

        merged["total_columns"] += len(r.get("select_columns", []))

        # 保存每条语句的详情
        merged["statements"].append(
            {
                "type": r.get("statement_type", "?"),
                "source_line": r.get("source_line", 0),
                "sql": r.get("sql", ""),
                "table_count": len(r.get("tables", [])),
                "where_count": len(r.get("where_conditions", [])),
                "column_count": len(r.get("select_columns", [])),
                "select_columns": r.get("select_columns", []),
                "error": None,
            }
        )

    return merged


from mcp import types as mcp_types

# ═══════════════════════════════════════════════════════════════
#  MCP Server
# ═══════════════════════════════════════════════════════════════

server = Server("sql-parser-for-finance-reporting")

# 项目根目录（用于解析相对路径）
PROJECT_ROOT = Path("/mnt/e/workspace/金融基础数据报送系统")


# ── 工具 1: parse_prc ──

async def _parse_prc_impl(prc_path: str) -> str:
    """parse_prc 的实现逻辑（可被 MCP 和直接调用复用）"""
    path = Path(prc_path)
    if not path.is_absolute():
        path = PROJECT_ROOT / prc_path

    if not path.exists():
        return json.dumps(
            {"error": f"文件不存在: {path}"}, ensure_ascii=False
        )

    try:
        content = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        content = path.read_text(encoding="gbk")

    sql_statements = extract_sql_from_plsql(content)

    if not sql_statements:
        return json.dumps(
            {"error": "未在文件中找到 SQL 语句", "file": str(path)},
            ensure_ascii=False,
        )

    all_results = []
    for stmt in sql_statements:
        parsed = parse_single_sql(stmt["sql"])
        parsed["statement_type"] = stmt["type"]
        parsed["source_line"] = stmt["line"]
        parsed["sql"] = stmt["sql"]
        all_results.append(parsed)

    summary = merge_results(all_results)
    summary["file"] = str(path)
    summary["total_statements"] = len(sql_statements)
    summary["parse_errors"] = sum(
        1 for r in all_results if "error" in r
    )

    return json.dumps(summary, ensure_ascii=False, indent=2)


# ── 工具 2: parse_sql ──

async def _parse_sql_impl(sql: str, dialect: str = "oracle") -> str:
    """parse_sql 的实现逻辑"""
    _ = dialect  # 当前仅支持 oracle，保留参数以备扩展
    result = parse_single_sql(sql)
    return json.dumps(result, ensure_ascii=False, indent=2)


# ── 工具注册 ──

@server.list_tools()
async def list_tools() -> list[mcp_types.Tool]:
    """向 MCP 客户端声明可用工具及其参数 schema"""
    return [
        mcp_types.Tool(
            name="parse_prc",
            description=(
                "解析 Oracle 存储过程文件 (.prc)，提取所有 SQL 语句并结构化。\n"
                "参数 prc_path: 文件路径（绝对路径或相对于项目根目录的路径）。\n"
                "返回 JSON: tables（表依赖）, joins（JOIN+ON条件）, "
                "where_conditions（WHERE条件）, select_columns（SELECT字段映射）。"
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "prc_path": {
                        "type": "string",
                        "description": ".prc 文件的路径",
                    }
                },
                "required": ["prc_path"],
            },
        ),
        mcp_types.Tool(
            name="parse_sql",
            description=(
                "直接解析一条 SQL 语句。\n"
                "参数 sql: SQL 语句文本。\n"
                "参数 dialect: SQL 方言，默认 oracle。\n"
                "返回 JSON: tables, joins, where_conditions, select_columns。"
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "sql": {
                        "type": "string",
                        "description": "要解析的 SQL 语句",
                    },
                    "dialect": {
                        "type": "string",
                        "description": "SQL 方言（默认 oracle）",
                        "default": "oracle",
                    },
                },
                "required": ["sql"],
            },
        ),
    ]


@server.call_tool()
async def call_tool(
    name: str, arguments: dict
) -> list[mcp_types.TextContent]:
    """处理 MCP 客户端的工具调用请求"""
    if name == "parse_prc":
        prc_path = arguments.get("prc_path", "")
        result = await _parse_prc_impl(prc_path)
        return [mcp_types.TextContent(type="text", text=result)]

    elif name == "parse_sql":
        sql = arguments.get("sql", "")
        dialect = arguments.get("dialect", "oracle")
        result = await _parse_sql_impl(sql, dialect)
        return [mcp_types.TextContent(type="text", text=result)]

    else:
        return [
            mcp_types.TextContent(
                type="text",
                text=json.dumps({"error": f"未知工具: {name}"}),
            )
        ]


# ═══════════════════════════════════════════════════════════════
#  入口
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    async def main():
        async with stdio_server() as (read_stream, write_stream):
            await server.run(
                read_stream,
                write_stream,
                server.create_initialization_options(),
            )

    asyncio.run(main())
