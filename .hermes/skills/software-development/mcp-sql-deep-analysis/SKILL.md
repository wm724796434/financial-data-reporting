---
name: mcp-sql-deep-analysis
description: 使用 MCP SQL 解析器深度分析存储过程/SQL 文件，输出 JSON 结构的 FROM 源表、WHERE 条件、INNER JOIN 关联和字段取数逻辑。parse_prc（v1.1+）一次调用即可获得全部数据，parse_sql 用于单条 SQL 解析或逐条 WHERE 归属。
version: 1.1.0
category: software-development
---

# MCP SQL 深度分析

## 触发条件

- 用户要求"分析存储过程的取数逻辑"
- 用户要求"解析 .prc/.sql 文件的 SQL 结构，输出 JSON"
- 用户要求输出 FROM 源表、WHERE 条件、INNER JOIN 关联、字段取数逻辑的完整 JSON
- 需要逐字段回答"XX 字段从哪个源字段取值"

## 前置条件

- MCP SQL 解析器已配置（`mcp_sql_parser_parse_prc` 和 `mcp_sql_parser_parse_sql` 工具可用）
- Python 标准库即可（`re`, `json`），无需额外依赖（`sqlparse` 为可选增强）

## 两个 MCP 工具的能力边界

| 工具 | 输入 | 输出 | 不输出 |
|------|------|------|--------|
| `parse_prc` | .prc 文件路径 | tables, joins, where_conditions（全局汇总）, statements（含 sql 文本 + **select_columns**） | — |
| `parse_sql` | SQL 语句文本 | tables, joins, where_conditions, select_columns | — |

**核心结论**：`parse_prc` 已内置返回 `select_columns`（v1.1+），一次调用即可拿到全部数据。`parse_sql` 用于单独解析 SQL 片段时使用。

---

## 工作流（两步法）

### 第一步（主路径）：parse_prc — 一次调用获取全部数据

```python
result = mcp_sql_parser_parse_prc(prc_path="/path/to/file.prc")
```

**获取信息**（一次调用全部拿到）：
- `tables[]` — 所有涉及的表（full_name, alias）
- `joins[]` — 所有 JOIN 关系（type, table, alias, on_conditions[], role: "过滤"/"仅字段补充"）
- `where_conditions[]` — 所有 WHERE 条件（字符串数组，全局汇总）
- `statements[].sql` — 每条 SQL 的完整文本
- `statements[].select_columns[]` — **每条 SQL 的字段映射**（expression + alias）
- `statements[].type` — SQL 类型（INSERT/SELECT/MERGE 等）
- `statements[].source_line` — 起始行号

**⚠️ 注意**：
- `where_conditions` 是**全局汇总**（所有 SQL 语句的 WHERE 条件混在一起），不区分是哪条语句的条件
- 如需**逐条 SQL 级别的 WHERE**，直接用 `parse_sql(statements[i].sql)` 获取

### 第二步（补充）：parse_sql — 逐条获取 WHERE 归属

当需要知道"哪个 WHERE 条件属于哪条 SQL"时，对关键 SQL 逐条调用：

```python
for stmt in result["statements"]:
    if stmt["type"] in ("INSERT", "MERGE"):
        detail = mcp_sql_parser_parse_sql(sql=stmt["sql"])
        # detail.where_conditions 是该条 SQL 独立的 WHERE 条件
```

---

## 旧版工作流（parse_prc v1.0 兼容，已废弃）

<details>
<summary>旧版需要从源码文件提取 SQL 再逐条 parse_sql，点击展开</summary>

旧版 parse_prc 不返回 sql 文本和 select_columns，需要：
1. parse_prc → 获取语句位置
2. 分号分割提取 SQL 文本
3. parse_sql 逐条解析
4. 整合输出

此工作流仅在 parse_prc 版本 < 1.1 时需要，现已废弃。

</details>

## JSON 输出参考

```json
{
  "file": "源文件完整路径",
  "file_type": "prc",
  "parse_summary": {
    "total_statements": 5,
    "parse_errors": 0
  },
  "source_tables": [
    { "full_name": "SMTMODS.L_ACCT_LOAN AS A", "alias": "A" }
  ],
  "all_joins": [
    {
      "type": "INNER",
      "table": "SMTMODS.L_CUST_ALL AS B",
      "alias": "B",
      "on_conditions": ["A.CUST_ID = B.CUST_ID"],
      "role": "过滤"
    }
  ],
  "all_where_conditions": [
    "A.DATA_DATE = IS_DATE",
    "A.DRAWDOWN_AMT > 0"
  ],
  "statements": [
    {
      "type": "INSERT",
      "source_line": 59,
      "sql": "INSERT INTO PBOCD_JS_102_XDQYXX(...) SELECT ... FROM ... WHERE ...",
      "select_columns": [
        {
          "expression": "A.LOAN_NUM",
          "alias": "LOAN_NUM"
        },
        {
          "expression": "CASE WHEN A.ORG_NUM LIKE '51%' THEN '...' END",
          "alias": "ORG_CODE"
        }
      ]
    }
  ]
}
```
## 完整执行脚本（整合输出示例）

```python
import json

# 直接使用 parse_prc 的结果（v1.1+ 已包含 select_columns）
# result = mcp_sql_parser_parse_prc(prc_path="/path/to/file.prc")

def build_field_mapping_report(prc_result):
    """从 parse_prc 结果构建字段映射报告"""
    report = {
        "file": prc_result.get("file"),
        "summary": {
            "total_statements": prc_result.get("total_statements"),
            "parse_errors": prc_result.get("parse_errors"),
        },
        "source_tables": prc_result.get("tables", []),
        "all_joins": prc_result.get("joins", []),
        "all_where_conditions": prc_result.get("where_conditions", []),
        "statements": []
    }
    
    for stmt in prc_result.get("statements", []):
        entry = {
            "type": stmt["type"],
            "source_line": stmt["source_line"],
            "sql": stmt.get("sql", ""),
            "field_mappings": []
        }
        
        for col in stmt.get("select_columns", []):
            expr = col["expression"]
            target = col.get("alias") or "(无别名)"
            
            # 分类字段映射类型
            is_calc = any(kw in expr.upper() for kw in ["CASE", "DECODE", "NVL", "NULL", "TRUNC", "("])
            
            entry["field_mappings"].append({
                "target_field": target,
                "source_expression": expr,
                "is_calculated": is_calc,
            })
        
        report["statements"].append(entry)
    
    return report

# 输出
# print(json.dumps(build_field_mapping_report(prc_result), ensure_ascii=False, indent=2))
```

**注**：如需逐条 SQL 的独立 WHERE 条件，对每条 `stmt.sql` 调 `parse_sql` 即可。

---

## 实际使用示例

### 示例 1：分析 .prc 文件（推荐方式）

```
用户：解析 bsp_sp_js_102_xdqyxx.prc 的取数逻辑，输出 JSON

Agent 执行：
1. mcp_sql_parser_parse_prc(prc_path="源码解析/加工层存储/bsp_sp_js_102_xdqyxx.prc")
   → 直接获取 tables, joins, where_conditions, 以及每条 statement 的 sql 文本 + select_columns

2. 从 statements 组装最终的 JSON 输出即可
```

### 示例 2：单独分析一条 SQL

```
用户：解析这条 SQL 的字段取数逻辑

Agent 执行：
1. mcp_sql_parser_parse_sql(sql="SELECT ... FROM ... WHERE ...")
   → 直接获取 tables, joins, where_conditions, select_columns
```

### 示例 3：需要逐条 SQL 的 WHERE 归属

```
用户：INSERT 语句中哪些条件在 WHERE、哪些在 JOIN ON？

Agent 执行：
1. parse_prc → 获取 INSERT 语句的 sql 文本
2. parse_sql(sql=insert_sql) → 获取该语句独立的 where_conditions 和 joins
```

---

## JSON 输出字段速查

| JSON 路径 | 含义 | 来源 |
|-----------|------|------|
| `.global.all_tables[]` | 所有涉及的源表（含别名） | parse_prc |
| `.global.all_joins[]` | 所有 JOIN 关系（含 ON 条件和 role） | parse_prc |
| `.global.all_where_conditions[]` | 所有 WHERE 条件（全局汇总） | parse_prc |
| `.statements[].type` | SQL 类型（INSERT/SELECT/MERGE） | parse_prc |
| `.statements[].sql` | SQL 完整文本 | parse_prc v1.1+ |
| `.statements[].select_columns[]` | 该条 SQL 的字段取数逻辑 | parse_prc v1.1+ |
| `.statements[].select_columns[].expression` | 源字段表达式 | parse_prc |
| `.statements[].select_columns[].alias` | 目标字段别名 | parse_prc |

**⚠️ 以下字段需单独调 parse_sql 获取（逐条 WHERE 归属）**：
| `.statements[].from_tables[]` | 该条 SQL 的 FROM 源表 | parse_sql |
| `.statements[].where_conditions[]` | 该条 SQL 的 WHERE 条件 | parse_sql |
| `.statements[].inner_joins[]` | 该条 SQL 的 INNER JOIN | parse_sql |

---

## 注意事项（陷阱清单）

### 1. parse_prc 的 where_conditions 是全局汇总
- 来自不同 SQL 的 WHERE 条件混在一起，无法知道"哪个条件属于哪条 SQL"
- 需要逐条归属时，用 `parse_sql(statements[i].sql)` 获取单条 SQL 的 WHERE

### 2. INSERT 语句的目标字段名提取
- parse_prc v1.1+ 的 `statements[].select_columns[]` 直接包含 expression 和 alias
- alias 为 null 时，字段名来自 INSERT 的字段列表位置索引
- 项目中的 .prc 文件通常有行内注释（`-- → 目标字段`），可作为验证参考

### 3. 编码问题
- 源码解析目录的 .prc 文件为 UTF-8，可直接读取
- 原始备份（`源码/` 目录）为 GBK，parse_prc 工具会自动尝试两种编码

### 4. 大型存储过程
- parse_prc 工具已做优化（只解析 SQL，跳过 PL/SQL 逻辑）
- statements 中每条 SQL 的 select_columns 已在工具内部解析完毕

---

## 输出质量保障

1. **验证 parse_prc 无错误**：检查 `parse_errors == 0`
2. **验证关键 SQL 提取完整**：SQL 文本以分号结尾，包含 SELECT/FROM/WHERE 等关键字
3. **验证字段映射数量匹配**：`len(field_mappings)` 应等于 statements 中的 `column_count`
4. **对照源码注释**：项目中的字段映射注释（`-- → 目标字段`）可作为验证参考

---

## 扩展：批量分析多个文件

```python
FILES = [
    "源码解析/加工层存储/bsp_sp_js_102_xdqyxx.prc",
    "源码解析/加工层存储/bsp_sp_js_201_hdaszdkfs.prc",
]

results = []
for f in FILES:
    result = mcp_sql_parser_parse_prc(prc_path=f)
    results.append(result)

# 输出 JSON 数组
print(json.dumps(results, ensure_ascii=False, indent=2))
```

对于 3+ 文件，考虑用 `delegate_task` 并行处理。
