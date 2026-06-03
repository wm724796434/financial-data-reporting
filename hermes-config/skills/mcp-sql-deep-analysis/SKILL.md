---
name: mcp-sql-deep-analysis
description: 使用 MCP SQL 解析器深度分析存储过程/SQL 文件，输出 JSON 结构的 FROM 源表、WHERE 条件、INNER JOIN 关联和字段取数逻辑。parse_prc（v1.1+）一次调用即可获得全部数据，parse_sql 用于单条 SQL 解析或逐条 WHERE 归属。
version: 1.2.0
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

### 5. `parse_prc` MCP 工具与 `extract_sql_from_plsql()` 的字段名不一致 ⚠️
- MCP 工具 `mcp_sql_parser_parse_prc` 返回的 `statements[]` 使用 **`source_line`** 字段
- Python 模块 `extract_sql_from_plsql()` 返回的 dict 使用 **`line`** 字段（不是 `source_line`）
- 在 `execute_code` 中混用两种接口时务必注意字段名差异，否则触发 `KeyError`

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

---

## ⚠️ 使用本 skill 的铁律

**执行任何解析/生成任务前必须先 `skill_view` 加载本 skill。** 禁止凭记忆直接写脚本——本 skill 附带了 `scripts/batch_generate_docs.py`，多数批量生成场景可直接复用，无需重写。

**迁移 skill 时必须完整复制**：`skill_manage` 默认写入 `~/.hermes/skills/`。若需迁移到项目目录，必须同时复制 `scripts/` 和 `references/` 子目录。迁移后验证两处 SKILL.md 内容一致（避免旧副本被技能系统优先加载）。

**技能系统的扫描优先级**：`~/.hermes/skills/`（用户目录）优先于 `.hermes/skills/`（项目目录）。同名 skill 若两处各有一份，`skill_view` 会返回用户目录的版本。迁移后务必删除用户目录旧副本。

---

## 批量生成报表文档（取数范围 + 字段取值 Markdown）

当用户要求"为报表生成取数范围和字段取值文档"时使用此工作流。

### 高效方案

**不要逐个调 MCP 工具！** 用 `execute_code` 直接导入项目的 `scripts/mcp_sql_parser.py` 模块：

```python
import sys
sys.path.insert(0, '/path/to/project/scripts')
from mcp_sql_parser import extract_sql_from_plsql, parse_single_sql

# extract_sql_from_plsql(content: str) -> list[dict]  # [{type, sql, line}, ...]
# parse_single_sql(sql: str) -> dict                 # {tables, joins, where_conditions, select_columns}
```

**优先使用** `scripts/batch_generate_docs.py`（Markdown 表格格式）或 `scripts/generate_json_in_md.py`（JSON-in-MD 格式），无需重写。

### 命名映射规则

.prc 文件命名模式：`bsp_sp_js_{批次号}_{接口表简称}.prc`

- 接口表简称提取：正则 `r'bsp_sp_js_(\d+)_(.+)\.prc'`
- 全称：`JS_{批次号}_{简称大写}` → 匹配实体文件名
- 排除：`_his` 后缀（历史版本）、`spop`、`pbocd_table`（辅助程序）

### 输出文档模板

#### 取数范围

```markdown
# {报表名} — 取数范围

> 来源程序: `{prc文件名}`

## 数据源表（FROM）
- {表名}

## 关联条件（JOIN）
- {JOIN类型} JOIN {表名} ON {条件}

## 筛选条件（WHERE）
1. `{条件}`
```

#### 字段取值

```markdown
# {报表名} — 字段取值

> 来源程序: `{prc文件名}`

## 字段映射

| 序号 | 目标字段(alias) | 源表达式(expression) |
|------|----------------|---------------------|
| 1 | `FIELD_NAME` | `SOURCE_EXPRESSION` |
```

### 缺口处理（针对金融基础数据报送系统项目）

- **五篇大文章报表**（科技/绿色/普惠/养老/数字经济贷款，共12个）：无独立 .prc，数据从对应的 hda* 子程序派生（如 hdaszdkfs → 数字经济产业贷款）。详见 `references/project-mapping.md`
- **JS_204/JS_101 系列**：源码解析目录中无对应 .prc，数据可能来自其他系统或未收录
- **字段过滤**：字段映射中混入系统变量（`T.USERNAME`, `COUNT(1)`, `NULL`, `''`），生成文档时需手动过滤
- **WHERE 过滤**：`TABLE_NAME`/`PARTITION_NAME` 条件为分区管理，非业务筛选，应从取数范围中排除

---

### JSON-in-MD 输出格式（用户偏好格式）

当用户要求"JSON 格式放到 md 文件里"或"按照 json 的格式放到对应的 md 文件"时，使用此格式。与上方 Markdown 表格模板的区别：JSON 结构化数据放在 markdown 代码块内，保留完整机器可读信息。**优先使用 `scripts/generate_json_in_md.py` 生成，无需手写。**

#### 取数范围 JSON-in-MD

```markdown
# {报表名} — 取数范围

> 来源程序: `{prc文件名}`
> 解析日期: {日期}
> 语句总数: N，关键取数语句: M

```json
{
  "file": "...",
  "entity": "...",
  "parse_date": "...",
  "total_statements": 19,
  "key_extractions": 5,
  "data_extractions": [
    {
      "label": "放款数据（贷款发放 - INSERT INTO 主SELECT）",
      "source_line": 105,
      "type": "SELECT",
      "source_tables": [{"table": "SMTMODS.L_ACCT_LOAN AS A", "alias": "A"}],
      "joins": [
        {
          "type": "INNER",
          "table": "SMTMODS.L_CUST_ALL AS B",
          "alias": "B",
          "on_conditions": ["A.CUST_ID = B.CUST_ID"],
          "role": "过滤"
        }
      ],
      "business_where_conditions": [
        "A.DATA_DATE = IS_DATE",
        "SUBSTRING(A.ITEM_CD, 1, 4) IN ('1303', '1305', '7120', '1306')"
      ]
    }
  ]
}
```
```

#### 字段取值 JSON-in-MD

```markdown
# {报表名} — 字段取值

> 来源程序: `{prc文件名}`
> 解析日期: {日期}

```json
{
  "file": "...",
  "entity": "...",
  "parse_date": "...",
  "data_extractions": [
    {
      "label": "放款数据（贷款发放）",
      "source_line": 105,
      "type": "SELECT",
      "field_count": 38,
      "field_mappings": [
        {"expression": "A.LOAN_NUM AS LOAN_NUM", "alias": "LOAN_NUM"},
        {"expression": "CASE WHEN ... END AS PRODUCT_TYPE", "alias": "PRODUCT_TYPE"}
      ]
    }
  ]
}
```
```

#### JOIN 角色自动分类规则

- **INNER JOIN → `"role": "过滤"`**：ON 条件参与结果集筛选
- **LEFT JOIN → `"role": "仅字段补充"`**：ON 条件不参与筛选，仅为字段透传

#### WHERE 条件自动过滤规则

`business_where_conditions` 自动排除以下非业务 WHERE：
- 分区管理：`TABLE_NAME = '...'`、`PARTITION_NAME = '...'`
- 临时表操作：`DATA_DATE = VS_TEXT8`
- UPDATE/MERGE 硬编码修正：`CUST_NAME = '...'`、`CUST_ID_NO = 'G102...'`
- MERGE 匹配条件：`A.FRNBJGH = '990000'`、`FRNBJGH = '990000'`
- 固定值修正：`ORG_AREA_COD = '220381'`、`REG_AREA_CODE = '220381'`
- 部门类型判断：`SUBSTRING(A.DEPT_TYPE, ...)`、`NOT SUBSTRING(DEPT_TYPE, ...)`
- 企业规模过滤：`ENT_SCALE IN ('CS01', ...)`
- 客户名称模糊匹配：`CUST_NAME LIKE '%有限责任公司'`

#### 生成方式

使用 `scripts/generate_json_in_md.py`（通过 execute_code 运行）：

```python
import sys
sys.path.insert(0, f'{PROJECT_ROOT}/scripts')
from generate_json_in_md import process_prc_file

result = process_prc_file(
    prc_path='/path/to/file.prc',
    entity_name='单位贷款发生额信息_JS_201_DWDKFS',
    out_range_dir=f'{PROJECT_ROOT}/实体/取数范围',
    out_field_dir=f'{PROJECT_ROOT}/实体/字段取值',
    mcp_sql_parser_module=mcp_sql_parser,
)
```
