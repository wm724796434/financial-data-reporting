---
name: project-audit
description: 金融数据报送项目多维审计——代码层数据源合规审计 + 文档层内容质量审计 + 筛选条件码值完整性审计。每次审计自动生成时间戳审计报告。
category: devops
---

# Project Audit — 项目多维审计

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
Step 1: 执行审计命令（五个维度）
Step 2: 汇总结果到审计报告
Step 3: 将报告写入 审计报告_YYYYMMDD_HHMMSS.md
Step 4: 将审计发现同步到待优化事项/待优化清单.md
Step 5: git add + commit（可选）
```

---

## 维度一：代码层数据源合规审计

### 审计原则

原则上所有主数据应通过 `SMTMODS` schema（监管集市）取数。

> 详细的数据源溯源分析方法见 `references/数据源合规-溯源分析方法.md`——包括表名 Schema 对照表、分类判定规则、实体文件更新模板。

### 分类标准

| 标记 | 含义 | 处理方式 |
|------|------|---------|
| ✅ 合规 | FROM/JOIN 直接引用 `SMTMODS.表名` | 通过 |
| ⚠️ 间接引用 | 数据最终来自 SMTMODS，但经过中间表（如 `L_CUST_C_TMP`） | 建议优化为 SMTMODS 直取 |
| ❓ 存疑 | 数据源不确定是否从 SMTMODS 派生 | 需人工核查 |
| ❌ 违规 | 完全不引用 SMTMODS 或从非 SMTMODS 表直取 | 必须整改 |

### 审计命令

> ⚠️ **WSL 中文路径注意**：terminal 工具对含中文字符的 workdir 可能拒绝执行。如果遇到 `Blocked: workdir contains disallowed character` 错误，改用 `execute_code` + Python `subprocess.run(cwd=...)` 替代 terminal()。search_files / read_file / patch 等文件工具不受此影响。

```bash
# 1. 列出所有 schema 前缀表引用
grep -rohP '\b[A-Z_]+\.[A-Z_]+[A-Z]\w+' --include="*.prc" --include="*.sql" . | sort -u

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
  part2=$(awk '/^# 第二部分/,0' "$f" 2>/dev/null)
  if echo "$part2" | grep -qE '请查看源码|暂无对应|当前实体暂无'; then
    [ "$p2_count" -eq 0 ] && echo "  ✅ 无问题"
    p2_count=$((p2_count+1))
  fi
done
echo "合计: $p2_count"

# === 维度3：引用覆盖度 ===
echo "## 引用覆盖度"
no_smt=0; no_src=0; both=0
for f in 实体/*.md; do
  part2=$(awk '/^# 第二部分/,0' "$f" 2>/dev/null)
  hs=$(echo "$part2" | grep -c 'SMTMODS\.')
  hr=$(echo "$part2" | grep -c '\.prc`')
  [ "$hs" -eq 0 ] && [ "$hr" -gt 0 ] && no_smt=$((no_smt+1))
  [ "$hs" -gt 0 ] && [ "$hr" -eq 0 ] && no_src=$((no_src+1))
  [ "$hs" -eq 0 ] && [ "$hr" -eq 0 ] && both=$((both+1))
done
echo "缺集市表: $no_smt; 缺源码: $no_src; 两都缺: $both"

# === 维度4：内容质量深检 ===
echo "## 内容质量深检"
thin=0
false_positive=0
for f in 实体/*.md; do
  part2=$(awk '/^# 第二部分/,0' "$f" 2>/dev/null)
  echo "$part2" | grep -qE '请查看源码|暂无对应|当前实体暂无' && continue

  # ⚠️ 排除已知误报：五篇大文章汇总统计报表（无独立接口表、无独立 .prc）
  if echo "$(basename "$f")" | grep -qE '^五篇大文章'; then
    if echo "$part2" | grep -qE '汇总统计报表|无对应接口表'; then
      false_positive=$((false_positive+1))
      continue
    fi
  fi

  sql_count=$(echo "$part2" | grep -cE 'WHERE|DECODE|CASE WHEN|ITEM_CD|TYPE_ID|ACCT_TYP')
  role_count=$(echo "$part2" | grep -c '\\\\*\\\\*主表\\\\*\\\\*')

  # 兜底：有实质性业务规则但不含SQL关键词的文件也算通过
  if [ "$sql_count" -eq 0 ]; then
    rule_lines=$(echo "$part2" | grep -cE '参与方|渠道性质|映射规则|字段说明|业务筛选')
    [ "$rule_lines" -gt 2 ] && continue
  fi

  if [ "$sql_count" -eq 0 ] && [ "$role_count" -le 1 ]; then
    thin=$((thin+1))
    echo "  🟡 内容单薄: $(basename "$f")"
  fi
done
echo "合计: $thin（排除 $false_positive 个五篇大文章汇总报表等误报）"

# === 维度5：筛选条件码值完整性检查 ===
echo ""
echo "## 筛选条件码值完整性检查"
echo "检查实体文件Part2的WHERE条件是否注明了码表编码和码值含义"
has_code=0
no_code=0
for f in 实体/*.md; do
  part2=$(awk '/^# 第二部分/,0' "$f" 2>/dev/null)
  if echo "$part2" | grep -qE 'WHERE|AND\s+\w+\.\w+'; then
    if echo "$part2" | grep -q '码表A[0-9]\|码表C[0-9]'; then
      has_code=$((has_code+1))
    else
      echo "  🟡 缺码值标注: $(basename "$f")"
      no_code=$((no_code+1))
    fi
  fi
done
echo "有码值标注: $has_code"
echo "缺码值标注: $no_code"

# === 深度检查：条件数 vs 码值标注数 ===
echo ""
echo "## 深度检查：条件多但码值少"
for f in 实体/*.md; do
  part2=$(awk '/^# 第二部分/,0' "$f" 2>/dev/null)
  cond_lines=$(echo "$part2" | grep -cE '^\s*AND\s+\w+\.\w+')
  code_lines=$(echo "$part2" | grep -c '码表A[0-9]\|码表C[0-9]')
  if [ "$cond_lines" -gt 3 ] && [ "$code_lines" -eq 0 ]; then
    echo "  ⚠️ $cond_lines条件/0码值: $(basename "$f")"
  fi
done
```

> ⚠️ **审计命令的局限性**：以上审计命令基于 grep 正则匹配，只能检测以 `AND column.` 开头的 SQL 格式条件。实体文件中存在以下格式的筛选条件会被**漏判**：
> - Markdown 表格中描述的条件（如：`| ITEM_CD | IN ('130101','130104') | ... |`）
> - 内联文本中的条件（如：`— T.DATA_DATE = IS_DATE`）
> - 嵌套在子查询中的条件
> - 无表别名前缀的裸字段条件
> - UPDATE 语句中的条件
>
> 建议审计完成后**人工抽样验证 3-5 个文件**，确保没有漏判。

---

## Step 3：修复 → 验证 → 报告

**不要假设批量修复一次性成功。** 常见回环：脚本处理了 31 个文件但 3 个因 split 逻辑缺陷残留占位符，审计报告显示还有问题。

### 修复后验证流程

```bash
# 在修复完成后、生成报告之前，先验证
echo "=== 验证1：无占位符残留 ==="
grep -cE '请查看原文文件|共0个字段' 实体/*.md | grep -v ':0$'
echo "(空=通过)"

grep -cE '请查看源码|暂无对应|当前实体暂无' 实体/*.md | grep -v ':0$'
echo "(空=通过)"

echo "=== 验证2：无标题重复 ==="
grep -c '# 第二部分# 第二部分' 实体/*.md | grep -v ':0$'
echo "(空=通过)"
```

**只有当验证全部通过**后，再生成时间戳审计报告。如果验证失败，先修再报告。

审计完成后，将结果写入带时间戳的报告文件：

```bash
TS=$(date '+%Y%m%d_%H%M%S')
REPORT="审计报告_${TS}.md"

# 写入报告
{
  echo "# 实体文件内容质量审计报告"
  echo ""
  echo "**审计日期**：$(date '+%Y-%m-%d %H:%M')"
  echo "**审计范围**：实体/ 目录下全部 .md 文件"
  echo ""
  echo "---"
  echo ""
  echo "## 审计结论"
  echo ""
  echo "| 维度 | 结果 |"
  echo "|------|------|"
  echo "| Part1 占位符 | (执行结果) |"
  echo "| Part2 占位符 | (执行结果) |"
  echo "| 监管集市表引用 | (执行结果) |"
  echo "| 源码引用 | (执行结果) |"
  echo ""
  echo "---"
  echo ""
  echo "## 审计明细"
  echo ""
} > "$REPORT"

# 将审计命令的输出追加入报告
# (将 Part1/Part2/引用覆盖度 的输出通过 >> 追加)

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

> **批量修复经验**：参见 `references/a案例-担保合同审计修复.md`——包含合并同类项策略、分批处理原则、自动提取+人工审查的工作流。

## 已知案例（2026-05-25 最新）

**全量修复完成后（2026-05-24）：**
- ✅ Part1 占位符：8个文件已修复（4个有源码充实 + 4个无源码标注）
- ✅ Part2 占位符：40个文件已全部修复（26个有源码充实 + 14个无源码标注）
- ✅ 监管集市表引用：所有有源码文件均已补充 SMTMODS 表引用
- 审计报告自动生成：审计报告_20260524_002001.md

**代码层（2026-05-23）：**
- 49 张 SMTMODS 表引用
- 5 个违规程序（完全不经过 SMTMODS）

**首次执行 Step 4 同步（2026-05-25）：**
- 审计发现 5 大类问题 → 合并为 5 条待优化项写入 `待优化事项/待优化清单.md`
- 其中包括：标题重复（28个文件）、实体已标注源码未收录（14个文件）、Part2内容单薄（29个文件）、缺集市表（2个有源码不引用SMTMODS的文件）、两缺无未收录标注（2个五篇大文章文件）
- 合并同类项原则：同类问题合并为一条概括性记录，而非每个文件独立一条
- 审计报告自动生成：审计报告_20260525_100655.md

**新增维度五（2026-05-25 第二轮）：**
- ✅ 新增 **维度五：筛选条件码值完整性检查** — 审计实体文件 Part2 的 WHERE 条件是否注明了码表编码和码值含义
- ✅ 联合 `entity-file-organization` 技能新增"码值含义编写标准"章节
- ✅ 手动修复 2 个实体文件：3.9存量数字经济、3.10数字经济发生额（完整 WHERE 子句 + 码值表 + 存量/发生额差异对比）
- ⚠️ 自动批处理尝试 34 个文件但因格式异构仅成功 7 个（详见 entity-file-organization 技能的"批量调整流程"陷阱说明）
- 发现说明：实体文件格式高度异构（SQL 代码块/Markdown 表格/无序列表/内联文本四类），自动化脚本可靠性不足，推荐手工逐文件处理

**码值批量补充（2026-05-25 第三轮）：**
- ✅ 通过 delegate_task + 手工 patch 对 14 个实体文件添加了码值标注（含五篇大文章5个、存量贷款/担保/同业等9个）
- ✅ 创建 entity-file-organization/references/常用码表速查.md（集中记录 A0004/A0005/A0006/A0010/C0003 等常见码表映射）
- ⚠️ 剩余 22 个实体文件的筛选条件来自中间表/交易表/存款表（非 SMTMODS 已知码表字段），已留待后续补充
- ⚠️ 实体文件格式的异构性（SQL 块/表格/列表/内联文本四种形式共存）导致自动化批量脚本不可靠，必须手工逐文件读源码→查码表→写注释

---

## Step 4：同步审计发现到待优化清单

> **目标**：每次审计后，将发现的结构化问题自动同步到 `待优化事项/待优化清单.md`，形成持续优化的跟踪看板。

### 4.1 映射规则

审计发现按以下规则映射到待优化清单的两大层面八个子分类。**注意**：section ID 使用"一.1"格式（对应文件中 `### 1.1` 标题），非"一.1.1"——脚本解析标题行提取的 section ID 不包含第三层小数点，规则中的 section 值须与此一致。

| 审计发现类别 | → 待优化清单位置 | 示例建议整改方案 |
|------------|----------------|---------------|
| Part1 占位符（`共0个字段`、`请查看原文文件`） | **一.1** 实体文件问题 | 从发文原文提取摘要，补充表级业务说明和字段清单 |
| Part2 占位符（`请查看源码`、`暂无对应`） | **一.1** 实体文件问题 | 从对应 .prc 提取 WHERE 条件和 DECODE 映射，补充到第二部分 |
| 两缺（缺SMTMODS表+缺源码引用） | **一.1** 实体文件问题 | 确认源码是否应收录；若收录则补充引用，否则保持"未收录"标注 |
| 标题重复（`# 第二部分# 第二部分`） | **一.1** 实体文件问题 | 修正标题拼接错误 |
| 内容单薄（SQL规则不足3处） | **一.1** 实体文件问题 | 深入阅读对应 .prc 提取实质性筛选条件 |
| 筛选条件缺码值含义（WHERE条件未注明码表编码和码值含义） | **一.1** 实体文件问题 | 对照 `参考资料/监管集市/` 下对应表的码表摘要，逐个条件补充码表编码和码值含义注释，格式：`-- 码表<编码>：<码值>=<含义>` |
| 源码解析文件缺失/不完整 | **一.2** 源码解析文件问题 | 创建/补充源码解析文件 |
| index.md 索引缺失 | **一.3** 查询流程问题 | 补充索引条目 |
| AGENTS.md 规则问题 | **一.3** 查询流程问题 | 更新规则描述 |
| 文件编码/命名/格式问题 | **一.4** 其他文档问题 | 统一规范 |
| 缺集市表（有源码但不直接引用SMTMODS） | **二.3** 数据源合规 | 调查数据源链路，标注间接引用或改造 |
| 完全不引用SMTMODS | **二.3** 数据源合规 | 改造为从SMTMODS取数 |
| 别名不匹配/temp表列名问题 | **二.1** 代码规范 | 修正列名定义 |
| 性能隐患（缺少索引等） | **二.2** 性能优化 | 分析执行计划 |
| 其他技术优化 | **二.4** 其他 | 参考具体建议 |

### 4.2 同步方式（方案B：Python脚本）

本技能自带 `scripts/sync_audit_to_todo.py` 脚本完成同步：

```bash
# 从本技能目录调用脚本
SKILL_DIR=~/.hermes/skills/project-audit

# 1. 执行审计，获取发现（略）

# 2. 构造审计发现JSON文件并保存到 /tmp/audit_findings.json
cat > /tmp/audit_findings.json << 'EOF'
[
  {
    "description": "标题重复错误: 共28个实体文件",
    "files": "实体/个人存款发生额信息_JS_202_GRCKFS.md、实体/个人客户基础信息_JS_102_GRKHXX.md、...",
    "priority": "P2"
  }
]
EOF

# 3. 执行同步
python3 "$SKILL_DIR/scripts/sync_audit_to_todo.py" --from-file /tmp/audit_findings.json
```

**合并同类项原则**：当大量文件出现相同的同类问题时（如28个文件都有标题重复错误），建议合并为一条概括性记录，在"涉及文件"列列出全部文件名。避免在待优化清单中写入28条相同类型的独立记录。

### 4.3 同步原则

1. **审计报告（原有）** — 单次快照，保留完整的原始审计证据
2. **待优化清单（新增同步）** — 持续看板，累积所有发现的问题及进度
3. **去重原则**：已有完全相同的"问题描述"的不重复写入
4. **状态初始值**：新写入条目统一标记为 🔴 待处理
5. **来源标记**：审计自动写入的标记来源为 `审计自动`，人工发现的标记为 `人工发现`

### 4.4 同步后的Actions

- 审计完成后，**必须验证**待优化清单中新增的条目是否正确
- 如果本条对话中已经修复了某些问题（例如修复了标题重复），则**不再**将这些已修复项写入待优化清单
- 写入后检查待优化清单的文件格式是否完整（表格行是否正确对齐）

### 4.5 常见陷阱

| 陷阱 | 症状 | 解决方案 |
|------|------|---------|
| **Section ID 不匹配** | 脚本输出"找不到插入位置"或写入到错误位置 | 确认 RULES 中的 section 值与文件 `### 1.1` 标题解析结果一致。脚本解析 `### 1.1实体文件问题` 为 `一.1`，不是 `一.1.1` |
| **sed 批量替换误伤** | 用 `sed -i 's/🔴 待处理/🟡 处理中/'` 替换状态时，所有行的状态都被改了，包括不该动的行 | 不要用 sed 做宽匹配替换表格状态列。改用行号精确定位 `sed -i '18s/🔴/🟢/'`，或用 Python 脚本逐行匹配问题描述后再替换 |
| **表格为空时插入失败** | 脚本说"成功写入N条"但文件未变化 | 空表格只有 `|---|` 分隔行没有下方数据行时，insert_pos 指向上方表头行。需先在表格中保留一行空数据行 `\|   \|          \|` |
| **JSON 中的中文引号** | Python 报 SyntaxError 或 JSON 解析失败 | 使用英文引号包裹 JSON 字符串，内容中的中文引号不会影响 JSON 解析 |
| **待优化清单中序号重复** | 同一个 section 下出现两个相同编号 | 脚本已按最大编号+1分配，但手动编辑文件后需检查 section_counts 是否正确读取 |
| **写入后 markdown 表格渲染异常** | 表格列数不对齐或渲染为纯文本 | 检查每一行的"|"数量是否一致，确保"涉及文件"列内容不包含未转义的"|"字符 |
