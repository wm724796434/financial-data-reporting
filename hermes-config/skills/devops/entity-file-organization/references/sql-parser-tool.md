# SQL 解析器工具（MCP）

## 概述

`scripts/mcp_sql_parser.py` 是一个 MCP server，提供 SQL 解析能力，自动从 Oracle 存储过程 (.prc) 中提取结构化信息。用于支持实体文件质量保障中的**交叉验证**和**取数条件提取**。

## 工具

注册为 Hermes Agent 的 MCP server（配置在 `~/.hermes/config.yaml`），Agent 重启后自动发现。提供两个工具：

### `parse_prc` — 解析 .prc 文件

```
输入：.prc 文件路径（绝对路径或相对于项目根目录）
输出：
  - tables: [{full_name, alias}, ...]       表依赖（去重，含 schema 前缀）
  - joins: [{type, table, on_conditions, role}, ...]  JOIN 关系
    - role: "过滤"（INNER JOIN）/ "仅字段补充"（LEFT JOIN）
  - where_conditions: [...]                  WHERE 条件列表
  - select_columns: [{expression, alias}]    SELECT 字段映射
  - total_statements: N                     提取到的 SQL 语句数
  - parse_errors: N                         解析失败的语句数
```

### `parse_sql` — 解析单条 SQL

```
输入：sql（SQL 文本）, dialect（默认 oracle）
输出：同上（单条 SQL 的 tables/joins/where_conditions/select_columns）
```

## 实体文件质量保障中的应用

### 场景 1：交叉验证实体文件的取数条件

当需要验证实体文件 Part2 第 4 节的取数筛选条件是否与源码一致时：

```
1. Agent 调用 mcp_sql_parser_parse_prc(prc_path="源码解析/加工层存储/xxx.prc")
2. 将返回的 where_conditions + joins[role="过滤"] 与实体文件中的取数条件对比
3. 检查遗漏的过滤条件、错误的表名、错误的 JOIN 类型标注
```

### 场景 2：快速获取表依赖

当需要知道某个报表引用了哪些监管集市表时，直接调 `parse_prc` 看 `tables` 字段，无需人工通读源码。

### 场景 3：补充缺失的 JOIN ON 条件

Oracle 存储过程中常把额外过滤条件写在 INNER JOIN 的 ON 子句中（如 `ON ... AND C.CUST_TYP <> '3'`）。人工阅读容易遗漏。`parse_prc` 的 `joins[].on_conditions` 自动提取这些隐藏条件。

## 已知局限

1. **动态 SQL（EXECUTE IMMEDIATE）无法解析** — 字符串拼接的 SQL 超出 sqlglot 能力范围，需人工审查
2. **部分 Oracle 特有语法可能被 sqlglot 转换** — 如 `NOT LIKE` 在某些上下文中可能被改写，导致条件丢失
3. **临时表字段映射** — 存储过程中分散定义的临时表，字段级映射可能需要人工补充
4. **覆盖率** — 约 80-90% 的 SQL 条件可自动提取，剩余需人工确认

## 依赖

- Python: sqlglot 30.8.0+, mcp 1.27.1+
- 安装: `uv pip install --python /home/wm/.hermes/hermes-agent/.venv/bin/python3 sqlglot mcp`
