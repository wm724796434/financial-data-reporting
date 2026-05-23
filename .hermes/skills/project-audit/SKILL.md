---
name: project-audit
description: 金融数据报送项目双维审计——代码层数据源合规审计 + 文档层内容质量审计。覆盖源码文件（.prc/.sql）的 SMTMODS 合规性和实体文件（.md）的内容完整性。
category: devops
---

# Project Audit — 项目双维审计

## 触发条件

遇到以下情况时加载本技能：
- 用户要求"审计"、"检查"、"审查"项目中的源码或文档质量
- 需要验证数据源是否合规（是否经过 SMTMODS 监管集市）
- 需要检查实体文件的 Part1/Part2 是否有实质内容还是占位符
- 用户要求"看看哪些地方需要改进"

## 审计维度总览

| 维度 | 审计对象 | 检查内容 | 发现的问题类型 |
|------|---------|---------|---------------|
| **代码层** | `.prc`/`.sql` 文件 | FROM/JOIN 是否引用 SMTMODS | 数据源合规违规 |
| **文档层** | `实体/*.md` 文件 | Part1/Part2 是否有实质内容 | 文档内容质量缺陷 |

---

## 维度一：代码层数据源合规审计

### 审计原则

原则上所有主数据应通过 `SMTMODS` schema（监管集市）取数。`SMTMODS` 是经过数据治理的统一数据源，直接引用上游业务系统或其他程序的输出接口表会导致数据链路不清晰、耦合度高。

### 分类标准

| 标记 | 含义 | 处理方式 |
|------|------|---------|
| ✅ 合规 | FROM/JOIN 直接引用 `SMTMODS.表名` | 通过 |
| ⚠️ 间接引用 | 数据最终来自 SMTMODS，但经过中间表（如 `L_CUST_C_TMP`） | 建议优化为 SMTMODS 直取 |
| ❓ 存疑 | 数据源不确定是否从 SMTMODS 派生 | 需人工核查 |
| ❌ 违规 | 完全不引用 SMTMODS 或从非 SMTMODS 表直取 | 必须整改 |

### 审计命令

```bash
# 1. 列出所有 schema 前缀表引用
grep -rohP '\b[A-Z_]+\.\w+' --include="*.prc" --include="*.sql" . | sort -u

# 2. 提取 FROM/JOIN 中的 SMTMODS 表
grep -rohP '(FROM|JOIN)\s+SMTMODS\.\w+' --include="*.prc" --include="*.sql" .

# 3. 提取 FROM/JOIN 中的裸表名（无 schema 前缀）
grep -rohP '(FROM|JOIN)\s+(\w+)\s' --include="*.prc" --include="*.sql" . | grep -oP '\w+' | sort -fu | grep -vP '^(AND|OR|ON|AS|IN|IS|NOT|NULL|WHERE|SELECT|LEFT|RIGHT|INNER|OUTER|CROSS|FULL|SYS)$'

# 4. 查找完全不引用 SMTMODS 的程序
for f in $(find . -name "*.prc" -o -name "*.sql"); do
    if [ "$(grep -c 'SMTMODS\.' "$f")" -eq 0 ]; then echo "$f"; fi
done

# 5. 逐个检查违规程序的数据源
grep -nP '(FROM|JOIN|INSERT\s+INTO)\s+\w' <程序路径>
```

### 裸表分类规则

将裸表名和其他 schema 的表引用分为四类：

| 分类 | 特征 | 评估 | 处理建议 |
|------|------|------|---------|
| **中间表/派生表** | 表名含 `_TMP`/`_TEMP`/`_SQ`，或由总调从SMTMODS生成 | 数据最终来源合规 | 可接受，但需确认中间表生成逻辑是否及时同步 |
| **跨报表接口表** | 引用 `JS_xxx` / `PBOCD_JS_xxx` 等目标表（其他程序的输出） | 间接合规 | 建议改为直接走SMTMODS，减少级联依赖 |
| **配置/映射表** | `SPOP_CONFIG`、`CODE_DICTIONARY`、`ORG_NEW`、`M_*` 等 | 非业务数据源 | 可接受 |
| **上游业务系统直取** | 表名无 SMTMODS 前缀，且不在上述三类中 | ❌ 真正的违规 | 需改造为走监管集市 |

---

## 维度二：文档层内容质量审计

### 审计维度

| 维度 | 标准 | 方法 |
|------|------|------|
| Part1 内容完整性 | 发文原文要求应有摘要，不得仅写"请查看原文文件" | 扫描 Part1 中 `请查看原文文件`、`共0个字段` 等占位符 |
| Part2 内容完整性 | 代码取数业务范围应有实质业务规则，不得仅写"请查看源码" | 扫描 Part2 中 `请查看源码`、`暂无对应`、`当前实体暂无` 等占位符 |
| 监管集市表引用 | Part2 必须列出实际引用的 SMTMODS 表 | 检查 Part2 中 `SMTMODS.` 引用 |
| 源码引用 | Part2 必须引用对应的 `.prc`/`.sql` 文件 | 检查 Part2 中 `.prc`\` 引用 |

### 审计命令

```bash
# Part1 占位符检查
for f in 实体/*.md; do
  part1=$(awk '/^# 第一部分/,/^# 第二部分/' "$f")
  if echo "$part1" | grep -q '请查看原文文件'; then
    echo "P1占位符: $(basename $f)"
  fi
done

# Part2 占位符检查
for f in 实体/*.md; do
  part2=$(awk '/^# 第二部分/,0' "$f")
  if echo "$part2" | grep -qE '请查看源码|暂无对应|当前实体暂无'; then
    echo "P2占位符: $(basename $f)"
  fi
done

# 监管集市表引用检查
for f in 实体/*.md; do
  part2=$(awk '/^# 第二部分/,0' "$f")
  if ! echo "$part2" | grep -q 'SMTMODS\.'; then
    echo "缺集市表引用: $(basename $f)"
  fi
done

# 源码文件引用检查
for f in 实体/*.md; do
  part2=$(awk '/^# 第二部分/,0' "$f")
  if ! echo "$part2" | grep -q '\.prc`'; then
    echo "缺源码引用: $(basename $f)"
  fi
done
```

### 实体文件内容质量门槛

创建或审计实体文件时，Part2 必须包含**实质性业务规则**而非占位符：

| 内容项 | 来源 | 反例 | 正例 |
|--------|------|------|------|
| 业务筛选条件 | SQL WHERE 子句 | "暂无" | `WHERE T.ITEM_CD IN ('130101', '130104')` |
| 代码映射 | DECODE/CASE WHEN | "见源码" | `DECODE(ID_TYPE, '236', 'A01', '21', 'A02')` |
| 监管集市表角色 | FROM/JOIN 用法 | 只有表名 | `SMTMODS.L_ACCT_LOAN` — **主表**—借据信息 |
| 特殊处理规则 | 源码中的处理逻辑 | "暂无规则" | 去重逻辑、名称清洗等 |

**🔴 关键陷阱**：不要仅看行数判断内容质量。文件有 70 行但全是"请查看原文文件"和"请查看源码"也算**不合格**。必须实际检查文件中是否包含 SQL 过滤条件、编码映射表、角色说明等实质性信息。检查方法：
1. 看是否有 SQL 片段关键词（`WHERE`、`DECODE`、`CASE WHEN`）
2. 看监管集市表引用行是否包含**加粗角色说明**（`**主表**`、`**客户信息**`）
3. 看 Part1 是否有实质性报送范围摘要而非"请查看原文文件"

### 实体-源码交叉覆盖检查

#### 方向A：有实体无源码

```bash
for entity in 实体/*.md; do
    base=$(basename "$entity")
    js=$(echo "$base" | grep -oP 'JS_\d+_\w+')
    if [ -n "$js" ]; then
        found=$(find 源码/ -name "*${js,,}*" 2>/dev/null)
        if [ -z "$found" ]; then
            echo "  有实体无源码: $base"
        fi
    fi
done
```

#### 方向B：有源码无实体

```bash
for f in 源码/加工层存储/*.prc; do
    base=$(basename "$f")
    js=$(echo "$base" | grep -oP 'js_\d+_\w+')
    if [ -n "$js" ]; then
        found=$(find 实体/ -name "*${js^^}*" 2>/dev/null)
        if [ -z "$found" ]; then
            echo "  有源码无实体: $base"
        fi
    fi
done
```

---

## 审计报告模板

### 总体结论表

```markdown
| 指标 | 数值 |
|------|------|
| 文件总数 | N |
| 代码层通过 | N |
| 文档层通过 | N |
```

### 代码层章节

```markdown
## 代码层审计

### 合规清单（✅ 从 SMTMODS 直取）

| 表名 | 中文名 |
|------|--------|
| `SMTMODS.xxx` | xxx表 |

### 违规程序

| 程序 | 用途 | 数据源 | 问题 |
|------|------|--------|------|
| xxx.prc | xxx | xxx | 无 SMTMODS |
```

### 文档层章节

```markdown
## 文档层审计

| 问题类型 | 数量 |
|---------|------|
| Part1 占位符 | N |
| Part2 占位符 | N |
| 缺集市表引用 | N |
| 缺源码引用 | N |
```

---

## 建议修复优先级

| 优先级 | 措施 | 适用场景 |
|--------|------|---------|
| P0 | 修复 Part1+Part2 均占位符的文件 | 需先确认对应的源码是否存在 |
| P1 | 修复 Part2 占位符的文件 | 从对应的 .prc 文件提取业务规则 |
| P2 | 补齐 Part2 中缺失的源表和源码引用 | 补充 SMTMODS 表引用 |
| P3 | 数据源合规违规程序整改 | 改造不走 SMTMODS 的程序 |

---

## 已知审计案例（金融基础数据报送系统，2026-05-23）

### 结果

| 审计维度 | 通过 | 发现问题 |
|---------|------|---------|
| 代码层 | 49 张 SMTMODS 表引用 | 5 个程序完全不经过 SMTMODS |
| 文档层 | 18/58 文件无问题 | 40 个文件存在 Part2 占位符（P1:7个双占位符 + P2:33个单占位符） |

### 行号前缀污染

扫描 `实体/`、`首页/`、`参考资料/发文原文/`、`参考资料/监管集市/`、`参考资料/数据源审计/` 等分类，用 hex 确认污染范围：

```bash
head -1 文件.md | xxd | head -3
# 如果开头是 "2020 2020 2031 7c" （空格+空格+空格+1+|）说明有行号前缀
```

批量修复：
```bash
for f in 实体/*.md 首页/*.md 参考资料/数据源审计/*.md; do
    sed -i 's/^[[:space:]]*[0-9]\+|//' "$f"
done
```
