---
name: structured-repo-query
description: "Query codebases that have their own structured documentation index with a defined query protocol — read the index first, then summaries, only then deep-dive. Prevents skipping-surface mistakes."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [codebase-query, documentation, index, AGENTS.md, CLAUDE.md, knowledge-base, code-review, investigation]
    related_skills: [codebase-inspection, systematic-debugging]
---

# Structured Repository Query

## When to Use

Use this skill whenever you're working in a project that has its **own structured documentation and a defined query protocol**. Signals to look for:

- `AGENTS.md` or `CLAUDE.md` in the project root that defines a query process
- A `综合/` (comprehensive) directory with index files like `功能模块映射.md`, `源码清单.md`
- A `实体/` (entity/summary) directory with per-module summaries
- A `源码解析/` (source analysis) directory with annotated source code
- Any project that says "read X before Y" or "use this file for function-to-file mapping"

**Do NOT use for** raw codebases with no documentation structure — use `codebase-inspection` or direct `search_files` instead.

## Core Protocol

### Rule 1: Index First, Search Last

```
AGENTS.md/CLAUDE.md query protocol
        │
        ▼
  Index files (综合/功能模块映射.md, 源码清单.md)
        │
        ▼
  Entity summaries (实体/)
        │
        ▼
  Sampling verification (源码解析/ header blocks)
        │
        ▼
  Full deep-dive (only when user asks for details)
```

**NEVER** jump straight to `search_files` / `grep` / glob scanning when index files exist. The index was built precisely to answer the question you're about to ask — it's faster, more complete, and prevents skipped-module mistakes.

### Rule 2: Read the Protocol Before Touching Tools

When you see AGENTS.md with a "查询流程" (query flow) section, read the **entire** flow definition before making any tool calls. Common patterns:

- **场景A**: User asks "how does feature X work" → read 功能模块映射.md for file list, then 实体/ for summaries, then 抽样验证 (sample verify) from 源码解析/
- **场景B**: User asks "what files are in directory Y" → read 源码清单.md
- **场景C**: Cross-module dependency tracing → read 实体/ for dependency sections
- **场景D**: Index links broken → fallback to 功能模块映射.md or 源码清单.md
- **场景E**: User asks "what is file X" → read 实体/ summary, or 源码解析/ header block

### Rule 3: Never Make Absolute Absence Claims from a Single Search

If you search for files matching "memory" and find nothing, **do not** say "this project has no memory module." You might have:

- Used the wrong search terms (directory named `memdir/`, not `memory/`)
- Missed the index file that explicitly lists the module (功能模块映射.md lists "记忆系统")
- Hit a tool limitation (search_files with certain patterns can return false negatives)

**Always check the project's own index first.** If the index lists a functional area you didn't find via search, trust the index and investigate.

### Rule 4: Cross-Validate Summaries Against Source

Entity/summary files are **second-hand** — they can be stale or wrong. Before citing them in an answer:

1. Pick 1-3 of the most critical files from the entity's file list
2. Read the **header comment block** (first 50-100 lines) of the corresponding source in 源码解析/
3. If entity and source disagree, trust the source and note the discrepancy

### Rule 5: Follow the File Scope Rules

Many structured documentation projects have "禁止行为" (forbidden actions). Check for these:

- **No modification of the source directory** (e.g., `ClaudeCode-main/` is read-only)
- **No full-file reads for overview questions** — use entity summaries; only read full source when user asks for implementation details
- **No glob scanning** if a module mapping file exists
- **No skipping update steps** after analysis (解析初始化文件.md, 源码清单.md, 实体/ must all be updated)

## Pitfalls

### 1. "It's small, I don't need the index" fallacy
Even a simple question ("does project X have Y?") benefits from the index. The index tells you Y's correct name, location, and all files involved — which ad-hoc search won't.

### 2. Using English search terms in Chinese-documented projects
The documentation might use Chinese terms (记忆系统, 功能模块映射) while source files use English names. Always scan the table of contents before searching.

### 3. Trusting a single search_files call
`search_files` has limitations: path resolution, regex edge cases, file_glob filtering. A zero-result doesn't mean "doesn't exist" — it means "try searching differently or check the index."

### 4. Skipping 抽样验证 (sampling verification)
Entity summaries can be out of date or overly simplified. Always read the header block of at least one core source file to ground your answer.

### 5. Jumping to general-purpose tools

### 6. Mixing business and implementation modes in one answer

**The #1 error in layered documentation projects.** When the user asks a business-layer question ("人行要求报送什么") and the entity file has both Part 1 (发文原文) and Part 2 (代码取数), it is tempting to include implementation details as "extra helpful context." **Don't.**

- Business questions → business answers only. Zero SQL, zero field names, zero table names, zero output table names.
- Implementation questions → implementation answers only. The full WHERE clause, all filters, no generic business descriptions.
- If uncertain about which mode → ask or default to business-layer overview first.

**The user's own words**: "一定要区分问题，我的问题是人行要求，这种情况是业务口径，一定要按照人行发文原文的角度回答，不牵扯任何技术口径和代码"

### 7. Entity file implementation section is incomplete or garbled

Entity files are maintained by humans and can be wrong. The `存量个人贷款信息_JS_201_CLGRDK.md` entity file had a garbled "业务筛选条件" section with disconnected SQL snippets. When the entity file's Part 2 is clearly broken or insufficient, **go directly to the source code** — read the actual INSERT INTO ... SELECT ... WHERE clause from the .prc file in `源码解析/`. But only do this for implementation-mode questions; for business-mode questions, the entity file's Part 1 is authoritative even if Part 2 is broken.
When the project provides specific tools (功能模块映射.md, 源码清单.md), they are almost always more reliable than grep/search_files for structural questions. The index was written by someone who already mapped the dependencies.

## Quick Reference

| Scenario | Step 1 | Step 2 | Step 3 |
|----------|--------|--------|--------|
| "How does feature X work?" | Project index (功能模块映射.md / 首页/index.md) | 实体/ summaries | 抽样验证 from 源码解析/ |
| "What files in directory Y?" | 源码清单.md / file inventory | — | — |
| "What does file X do?" | 实体/ summary | 源码解析/ header | (optional) full source |
| "Cross-module dependencies?" | Project index + 实体/ | — | — |
| "Is feature X present?" | Project index | — | — |
| "Field X's value logic?" | Project index → entity | Source analysis file | 字段级 deep-dive + 业务场景解释 |

## Financial Source Code Query Patterns

This section covers projects (like 金数源码 / 金融基础数据系统) where the documentation is organized by **business report (接口表)** rather than by source code module. These projects have specific patterns in common.

### Common Structure

```
首页/index.md         ← 一级路由：按业务域分组 + 按源码文件反向索引
实体/<报表名>.md      ← 功能/概述层：每份报表一个实体文件
源码解析/             ← 字段级取数逻辑：实际 SQL 代码
参考资料/监管集市/     ← 监管集市表字段级定义
参考资料/金融基础数据系统/ ← 监管机构原文文件
```

### Key Differences from Generic Structured Repos

| Aspect | General Pattern | 金数源码 Pattern |
|--------|----------------|-----------------|
| Index file | `综合/功能模块映射.md` | `首页/index.md` |
| Entity organization | Per source file | Per business report (接口表/JS_xxx) |
| Role of entity files | Code module summary | Report overview + business classification + source file mapping |
| Source files | Single type | 3 types: 加工层存储(.prc), 加工层特殊处理(.sql), 应用层特殊处理(.sql) |
| Field explanation | Direct code reading | Cross-reference with 监管集市表 field definitions |

### Specific Query Flow for 金融数据源码

#### Layer 1: 首页/index.md (一级路由)

**Scenario A**: User asks "what is XX report?"
→ Find report by business domain (贷款类, 存款类, 客户信息类, 票据类, etc.)
→ Click entity file link → Layer 2

**Scenario B**: User asks "what does XX program do?"
→ Check 按源码文件反向索引 section at end of index.md
→ Find which reports the program belongs to
→ Click entity file link → Layer 2

**Scenario C**: User asks "field X's 取数逻辑 (value logic)"
→ Layer 1 → Layer 2 → Layer 3 (field-level deep-dive into source analysis files)

**Forbidden**: Do NOT use glob/grep/search_files before reading index.md.

#### Layer 2: Entity File (功能/概述层)

Entity files contain:
- **报表说明**: 1-2 sentence summary from original regulatory document
- **业务分类**: 接口表代码, 中文名, 章节号
- **关键逻辑**: CASE WHEN rules, business judgment logic extracted from source
- **特殊处理规则**: Business rules from 加工层特殊处理 + 应用层特殊处理 SQL
- **涉及源码文件**: Sorted by role (数据生成/数据修正/数据引用)
- **引用的监管集市表**: SMTMODS tables referenced
- **字段清单**: Pointer to original document (NOT the field table itself)

#### Layer 3: Source Analysis (字段级取数逻辑)

When user asks for field-level detail:
1. Read the .prc or .sql file in `源码解析/`
2. Find the INSERT/SELECT column corresponding to the field
3. Trace the CASE WHEN / field mapping logic
4. Cross-reference source fields (`MATURITY_DT`, `MATURITY_DT_BEFORE`) with 监管集市表 definitions
5. Explain each business scenario in plain language

### Explaining SQL CASE WHEN Logic for Business Users

When explaining field-level logic, always:

1. **Show the SQL** — the current CASE WHEN block with line references
2. **Identify source fields** — which database fields feed into the logic
3. **Explain each scenario** — what each WHEN branch means in business terms:
   - Normal case: what happens most of the time
   - Edge cases: 展期 (extension), 缩期 (shortening), 核销 (write-off), etc.
4. **Reference the source tables** — which regulatory table (L_ACCT_LOAN, etc.) and which fields
5. **Show historical context** — if there's commented-out old logic, explain what changed and why (需求编号, 修改人, 修改原因)
6. **Distinguish the field from related fields** — e.g., LOAN_DUE_DATE (到期日) vs DEFER_END_DATE (展期到期日期) — explain which scenario sends data to which field

### Critical Rule: Question-Mode Routing

This is the most commonly violated rule in layered documentation projects. **Every question has a mode** — it targets either the **business-requirements layer** or the **technical-implementation layer**. You MUST identify which one and answer exclusively from that layer.

| Question phrasing | Mode | Answer from | Forbidden content |
|---|---|---|---|
| "要求报送什么" / "人行要求" / "发文规定" / "业务口径" | **Business** | 实体文件-第一部分（发文原文要求） | Code-level details: SQL WHERE, field names like GREEN_CREDIT_FLAG, output table names, procedure names |
| "怎么取数" / "取了哪些业务" / "筛选条件" / "取数逻辑" / "代码实现" | **Implementation** | 实体文件-第二部分（代码取数业务范围） + 源码解析 | Business-layer generic statements when concrete SQL logic exists |
| "是什么" / "做什么的" / "功能概述" | **Overview** | 实体文件-第一部分（简明概述） | Deep-dive into either layer; give 2-3 sentence summary first |

**Common mistake**: User asks "绿色贷款人行要求报送什么样的数据" → agent answers with `GREEN_CREDIT_FLAG = '1'` and output table names. **Wrong mode** — "人行要求" means business-layer only. Answer: "官方报送范围：报告期末存续且具备绿色贷款标识的贷款..." with zero reference to database fields or code.

**Another common mistake**: User asks "取了哪些业务" → agent reads only the entity file Part 1 (business requirements) and describes what should be taken, not what IS taken. **Wrong mode** — "取数" means implementation-layer: actual SQL WHERE conditions from Part 2.

**How to detect the mode**:
1. Scan the user's question for keywords: "要求/发文/人行/报送" → business; "取数/代码/筛选/条件/逻辑" → implementation
2. If ambiguous, default to **overview** (第一部分简明概述) and offer to go deeper
3. When the user has just corrected you about mixing modes, the **next question in the same topic** may switch modes — re-evaluate independently each turn

### Integration with Entity File Structure

Entity files are explicitly designed with this separation:
- **# 第一部分：发文原文要求（人行规范层）** — for business/requirement questions
- **# 第二部分：代码取数业务范围（实现层）** — for implementation questions

When the entity file's implementation section (Part 2) is incomplete, garbled, or missing critical WHERE conditions (as happened with `存量个人贷款信息_JS_201_CLGRDK.md`), fall through to the actual source code in `源码解析/` to extract the correct WHERE clause — but only for implementation-mode questions. Never cite source code for business-mode questions.

### Reports Not in Original Documents

Some reports exist in source code but not in regulatory original documents:
- JS_102_XDQYXX (小额企业信息)
- JS_201_CLZXDK (存量助学贷款)
- JS_201_HDACLHLDK (存贷款客户核对)
- JS_202_WQYBJY (完全一致交易)
- JS_202_FTYDWC_SMH (非同业单位存贷)

When querying these, note: "该报表无金融基础数据系统原文参考".

## Reference Files

- `references/claude-code-memory-system.md` — Concrete worked example showing what happens when you skip the protocol vs follow it, with the full Claude Code memory system architecture revealed by proper querying.
- `references/jinshu-source-code-query-protocol.md` — 金数源码项目特定查询协议：三层路由细节、实体文件结构、字段级取数逻辑解释模式、监管集市表交叉引用方式。

## Verification

Before answering, check:

- [ ] Did I read the AGENTS.md / CLAUDE.md query protocol first?
- [ ] Did I check the project's index file before searching?
- [ ] Did I use entity/summary files for overview questions?
- [ ] Did I sample-verify at least one source file header?
- [ ] Is my claim ("doesn't have X") verified against the index, not just search?
- [ ] For field-level logic: did I cross-reference source fields with table definitions?
- [ ] For field-level logic in 金数源码 context: did I also read the original regulatory document (原文) and compare implementation vs. requirement? (双源验证)
- [ ] Did I check for historical/modification context (commented-out code, change reasons)?
- [ ] Did I avoid modifying protected directories?
