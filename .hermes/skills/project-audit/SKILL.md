---
name: project-audit
description: 金融数据报送项目双维审计——代码层数据源合规审计 + 文档层内容质量审计。每次审计自动生成时间戳审计报告。
category: devops
---

# Project Audit — 项目双维审计

> ⚠️ **源文件**: 本 skill 的源文件在项目仓库 `.hermes/skills/project-audit/SKILL.md`，随版本控制。如需修改，请在项目目录中编辑源文件后重新 `skill_manage`。

## 触发条件

遇到以下情况时加载本技能：
- 用户要求"审计"、"检查"、"审查"项目中的源码或文档质量
- 需要验证数据源是否合规（是否经过 SMTMODS 监管集市）
- 需要检查实体文件的 Part1/Part2 是否有实质内容还是占位符
- 用户要求"看看哪些地方需要改进"

## 审计流程总览

每次审计按以下流程执行，最终自动生成带时间戳的审计报告文件：

```
Step 1: 执行审计命令（四个维度）
Step 2: 汇总结果到审计报告
Step 3: 将报告写入 审计报告_YYYYMMDD_HHMMSS.md
Step 4: git add + commit（可选）
```

---

## 维度一：代码层数据源合规审计

### 审计原则

原则上所有主数据应通过 `SMTMODS` schema（监管集市）取数。

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
grep -rohP '\b[A-Z_]+\.[A-Z_]+\w+' --include="*.prc" --include="*.sql" . | sort -u

# 2. 提取 FROM/JOIN 中的 SMTMODS 表
grep -rohP '(FROM|JOIN)\s+SMTMODS\.\w+' --include="*.prc" --include="*.sql" .

# 3. 提取 FROM/JOIN 中的裸表名
grep -rohP '(FROM|JOIN)\s+(\w+)\s' --include="*.prc" --include="*.sql" . | grep -oP '\w+' | sort -fu | grep -vP '^(AND|OR|ON|AS|IN|IS|NOT|NULL|WHERE|SELECT|LEFT|RIGHT|INNER|OUTER|CROSS|FULL|SYS)$'

# 4. 查找完全不引用 SMTMODS 的程序
for f in $(find . -name "*.prc" -o -name "*.sql"); do
    if [ "$(grep -c 'SMTMODS\.' "$f")" -eq 0 ]; then echo "$f"; fi
done
```

---

## 维度二：文档层内容质量审计

### 审计维度

| 维度 | 标准 | 方法 |
|------|------|------|
| Part1 内容完整性 | 发文原文要求应有摘要 | 扫描 `请查看原文文件`、`共0个字段` 占位符 |
| Part2 内容完整性 | 应有实质业务规则 | 扫描 `请查看源码`、`暂无对应`、`当前实体暂无` 等占位符 |
| 监管集市表引用 | 必须列出 SMTMODS 表 | 检查 Part2 中 `SMTMODS.` 引用 |
| 源码引用 | 必须引用 .prc/.sql 文件 | 检查 Part2 中 `.prc`\` 引用 |

### 审计命令

将以下命令的输出重定向到内存变量，用于生成审计报告：

```bash
# === 维度1：Part1 占位符 ===
echo "## Part1 占位符检查"
p1_count=0
for f in 实体/*.md; do
  name=$(basename "$f")
  part1=$(awk '/^# 第一部分/,/^# 第二部分/' "$f" 2>/dev/null)
  tags=""
  echo "$part1" | grep -q '请查看原文文件' && tags="$tags [原文占位符]"
  echo "$part1" | grep -q '共0个字段' && tags="$tags [字段数=0]"
  if [ -n "$tags" ]; then
    echo "  🔴 $tags  $name"
    p1_count=$((p1_count+1))
  fi
done
echo "合计: $p1_count"

# === 维度2：Part2 占位符 ===
echo "## Part2 占位符检查"
p2_count=0
for f in 实体/*.md; do
  name=$(basename "$f")
  part2=$(awk '/^# 第二部分/,0' "$f" 2>/dev/null)
  if echo "$part2" | grep -qE '请查看源码|暂无对应|当前实体暂无'; then
    echo "  🔴 $name"
    p2_count=$((p2_count+1))
  fi
done
echo "合计: $p2_count"

# === 维度3：引用覆盖度 ===
echo "## 引用覆盖度"
no_smt=0; no_src=0; both=0
for f in 实体/*.md; do
  name=$(basename "$f")
  part2=$(awk '/^# 第二部分/,0' "$f" 2>/dev/null)
  has_smt=$(echo "$part2" | grep -c 'SMTMODS\.')
  has_src=$(echo "$part2" | grep -c '\.prc`')
  [ "$has_smt" -eq 0 ] && [ "$has_src" -gt 0 ] && no_smt=$((no_smt+1)) && echo "  🟡 缺集市表 $name"
  [ "$has_smt" -gt 0 ] && [ "$has_src" -eq 0 ] && no_src=$((no_src+1)) && echo "  🟡 缺源码 $name"
  [ "$has_smt" -eq 0 ] && [ "$has_src" -eq 0 ] && both=$((both+1)) && echo "  🔴 两缺 $name"
done
# === 维度4：内容质量深检 ===
echo "## 内容质量深检"
thin=0
for f in 实体/*.md; do
  part2=$(awk '/^# 第二部分/,0' "$f" 2>/dev/null)
  echo "$part2" | grep -qE '请查看源码|暂无对应|当前实体暂无' && continue
  sql_count=$(echo "$part2" | grep -cE 'WHERE|DECODE|CASE WHEN|ITEM_CD|TYPE_ID|ACCT_TYP')
  role_count=$(echo "$part2" | grep -c '\\*\\*主表\\*\\*')
  if [ "$sql_count" -eq 0 ] && [ "$role_count" -le 1 ]; then
    thin=$((thin+1))
    echo "  🟡 内容单薄 $(basename "$f")"
  fi
done
echo "合计: $thin"
```

---

## Step 3：生成时间戳审计报告

审计完成后，将结果写入带时间戳的报告文件：

```bash
# 生成时间戳
TS=$(date '+%Y%m%d_%H%M%S')
REPORT="审计报告_${TS}.md"

# 写入报告头部
{
  echo "# 实体文件内容质量审计报告"
  echo ""
  echo "**审计日期**：$(date '+%Y-%m-%d %H:%M')"
  echo "**审计范围**：实体/ 目录下全部 N 个 .md 文件"
  echo ""
  echo "---"
  echo ""
  echo "## 审计结论"
  echo ""
  echo "| 维度 | 通过 | 有问题 |"
  echo "|------|------|--------|"
  echo "| Part1 内容完整性 | 50/58 | 8 |"
  echo "| Part2 内容完整性 | N/58 | N |"
  echo "| 监管集市表引用 | N/58 | N |"
  echo "| 源码引用 | N/58 | N |"
  echo ""
  echo "---"
  echo ""
} > "$REPORT"

# 追加各维度的详细结果
echo "## Part1 占位符检查" >> "$REPORT"
# ... 追加实际扫描结果 ...

echo "审计报告已生成：$REPORT"
```

---

## 建议修复优先级

| 优先级 | 措施 | 适用场景 |
|--------|------|---------|
| P0 | 修复 Part1+Part2 均占位符 | 需先确认对应源码是否存在 |
| P1 | 修复 Part2 占位符 | 从 .prc 提取业务规则 |
| P2 | 补齐缺失的源表和源码引用 | 补充 SMTMODS 表引用 |
| P3 | 内容充实（五篇大文章发生额类） | 补充 SQL 筛选条件 |

## 已知案例（2026-05-23）

代码层：49 张 SMTMODS 表引用，5 个违规程序
文档层：18/58 无问题，40 个文件存在 Part2 占位符
