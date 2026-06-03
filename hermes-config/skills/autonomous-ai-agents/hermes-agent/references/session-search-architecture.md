# session_search 内部架构

## 概述

`session_search` 是 Hermes Agent 的跨会话检索工具。它能搜索所有历史对话的原始记录，返回匹配话题的摘要。本文件记录了其底层存储、索引机制、保留策略和运行时行为。

---

## 数据库

| 项目 | 值 |
|------|-----|
| 类型 | **SQLite**（嵌入式关系型数据库，零配置，单文件） |
| 文件路径 | `~/.hermes/state.db` |
| 典型大小 | ~28 MB（取决于会话量和消息量；无硬性上限，仅受磁盘空间约束） |
| 早期内部版本 | 曾用 `~/.hermes/hermes.db`（已弃用）；检查两者以兼容旧安装 |

### 核心表

#### `sessions` — 会话元数据（~30 行）

```sql
CREATE TABLE sessions (
    id TEXT PRIMARY KEY,
    source TEXT NOT NULL,           -- 'cli', 'telegram', 'discord', ...
    user_id TEXT,
    model TEXT,
    model_config TEXT,
    system_prompt TEXT,
    parent_session_id TEXT,
    started_at REAL NOT NULL,
    ended_at REAL,
    end_reason TEXT,
    message_count INTEGER DEFAULT 0,
    tool_call_count INTEGER DEFAULT 0,
    input_tokens INTEGER DEFAULT 0,
    output_tokens INTEGER DEFAULT 0,
    cache_read_tokens INTEGER DEFAULT 0,
    cache_write_tokens INTEGER DEFAULT 0,
    reasoning_tokens INTEGER DEFAULT 0,
    billing_provider TEXT,
    billing_base_url TEXT,
    billing_mode TEXT,
    estimated_cost_usd REAL,
    actual_cost_usd REAL,
    cost_status TEXT,
    cost_source TEXT,
    pricing_version TEXT,
    title TEXT,
    api_call_count INTEGER DEFAULT 0,
    handoff_state TEXT,
    handoff_platform TEXT,
    handoff_error TEXT,
    FOREIGN KEY (parent_session_id) REFERENCES sessions(id)
);
```

键字段：
- `id` — 像 `20260521_082347_a52030` 这样的时间戳格式
- `source` — 对话来源平台
- `title` — 会话标题（可由用户用 `/title` 设置，或自动生成）
- `started_at` / `ended_at` — Unix 时间戳
- `message_count` / `tool_call_count` / `input_tokens` / `output_tokens` — 使用统计

#### `messages` — 完整对话记录（~1,900 行）

```sql
CREATE TABLE messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL REFERENCES sessions(id),
    role TEXT NOT NULL,             -- 'user', 'assistant', 'tool'
    content TEXT,                   -- 消息正文（完整存储）
    tool_call_id TEXT,
    tool_calls TEXT,                -- 工具调用的完整 JSON
    tool_name TEXT,
    timestamp REAL NOT NULL,
    token_count INTEGER,
    finish_reason TEXT,
    reasoning TEXT,                 -- thinking 标签内容（模型内部推理链）
    reasoning_content TEXT,
    reasoning_details TEXT,
    codex_reasoning_items TEXT,
    codex_message_items TEXT
);
```

存储内容：用户说的**每一句话**、助手的每次思考（`<thinking>` 标签）、每次工具调用、每次报错——全部完整记录。

### 状态元数据

`state_meta` 表跟踪已应用的迁移：

```sql
CREATE TABLE state_meta (key TEXT PRIMARY KEY, value TEXT);
```

示例值：`ghost_session_prune_v1`, `orphaned_compression_finalize_v1`。

---

## 全文搜索：FTS5 双重索引

为了支持会话历史搜索，消息内容在两个独立的 FTS5 虚拟表中建立索引。

### 标准 FTS5（`messages_fts`）

```sql
CREATE VIRTUAL TABLE messages_fts USING fts5(content);
```

- 使用 FTS5 **默认分词器**（按空格和标点符号切词）
- 建立倒排索引
- **英文表现良好**；中文表现较差（中文字之间无空格，默认分词器会将整个短语视为一个 token）

### Trigram FTS5（`messages_fts_trigram`）

```sql
CREATE VIRTUAL TABLE messages_fts_trigram USING fts5(
    content,
    tokenize='trigram'
);
```

- 使用 **trigram 分词器**
- 将文本切成连续的三个字符一组（n-grams）
- 例子：`"虚坛战一场"` → 三元组：`"虚坛"`, `"坛战"`, `"战一"`, `"一场"`
- **对中文至关重要**：不需要中文分词词典；任意关键词都能通过子串匹配命中
- 代价：索引体积更大（标准 FTS5 约 400 个索引行 vs trigram 版本约 2,200 行）

### 索引统计（参考数据）

| 索引表 | 行数 |
|---------|-------|
| `messages_fts_idx` | ~390 |
| `messages_fts_trigram_idx` | ~2,170 |
| `messages_fts_data` | ~410 |
| `messages_fts_trigram_data` | ~2,330 |

---

## 运行时搜索流程

当 agent 调用 `session_search(query="诗 游戏 古诗词 即兴")` 时：

```
1. Trigram FTS5 索引接收查询字符串
2. 切成 trigram："诗" "游" "戏" "古" "诗" "词" "即" "兴"
3. 在 messages_fts_trigram 中搜索包含这些 trigram 的消息
4. 将匹配的消息 ID 映射到会话 ID
5. 对每个匹配的会话，将完整转写输送给 LLM，生成摘要
6. 返回摘要列表（含时间戳、来源、会话标题）
```

查询项通过 `OR` 隐式连接。由于 trigram 分词器，即使很短的关键词（如 "诗"）也能匹配——三字符约束不适用于短于 3 个字符的词；FTS5 会回退到前缀匹配。

### 限制

| 项目 | 值 |
|------|-------|
| 匹配摘要上限 | 5（默认 3） |
| 结果形式 | LLM 生成的摘要，非原始文本 |
| 每次调用的成本 | 匹配数 × 一次 LLM 摘要调用 |

---

## 保留策略

在 `~/.hermes/config.yaml` 的 `sessions:` 部分配置：

```yaml
sessions:
  auto_prune: false          # 默认为 false —— 不自动清理
  retention_days: 90         # 保留策略上保留 90 天
  vacuum_after_prune: true   # 清理后执行 VACUUM 回收空间
  min_interval_hours: 24     # 清理间隔下限
```

关键点：
- **`auto_prune: false`（默认）**：所有会话永久保留，无自动删除
- 若启用，超过 `retention_days` 天的会话将被批量删除
- `vacuum_after_prune: true` 在清理后回收磁盘空间，防止数据库无限增长
- 若 `auto_prune` 保持关闭，数据库将无限增长，仅受磁盘大小限制

也可通过 CLI 手动清理：`hermes sessions prune --older-than N`

---

## 三层存储模型

如同对话中自然发现的那样，Hermes 使用三种不同机制来跨会话保留信息：

| 层 | 实现 | 范围 | 延迟 | 为何选择 |
|-----|------|---------|-------|---------|
| **memory** | `memory` 工具写入 `~/.hermes/state.db` | 短的事实条目（用户偏好、约定） | 零（每轮自动注入） | 高频可操作指引的即时可用性 |
| **longterm.md** | 外部文件（约定为 `~/longterm.md`） | 用户要求记住的完整内容 | 按需读取 | 需要人为策划的重要内容，避免 memory 被写满 |
| **session_search** | FTS5 搜索完整对话转写 | 所有原始对话 + 思考过程 | 中等（搜索 + LLM 摘要） | 不需要预先策划；所有历史都可检索 |

### 会话搜索能做什么，memory 不能

- 访问对话过程中发生的所有内容，包括被忽略的部分、修复过程、以及完整的讨论脉络
- 重新发现未显式保存到 memory 或 longterm.md 的信息
- 总结长时间对话中的模式

### 它不能做什么

- 不能提供零成本检索（每次调用都会触发 LLM 摘要）
- 不能保证排他性——原始对话中的内容与长期文件中存储的内容之间没有权威同步

---

## 故障排除

### Q：搜索什么也找不到

1. 检查数据库是否存在：`find ~/.hermes -name "*.db"`
2. 检查会话数量：`sqlite3 ~/.hermes/state.db "SELECT COUNT(*) FROM sessions;"`
3. 查询可能太具体；尝试用单个中文关键词扩大搜索，例如仅搜索 "诗"

### Q："诗"这个查询匹配到了不相关的中文内容

Trigram 分词器基于子串匹配。单个汉字 "诗" 作为一个 trigram token，会匹配到包含该字的任何中文文本。短关键词的回退前缀行为意味着单字符查询非常宽泛。如果结果嘈杂，可改用多字短语："对诗游戏 虚坛" 或 "游戏 诗的"

### Q：数据库在增长，我想要限制它

```bash
# 设置保留天数
hermes config set sessions.auto_prune true
hermes config set sessions.retention_days 30

# 手动清理
hermes sessions prune --older-than 30

# 查看当前大小
ls -lh ~/.hermes/state.db
```

### Q：我删了一个会话，但搜索仍能匹配到它

目前，`hermes sessions delete` 会删除 `sessions` 表中的条目，但**可能不会立即从 FTS5 索引中移除对应行**。FTS5 索引是消息的独立视图；消息记录可能仍然存在。清理旧会话的可靠方法是使用配置驱动的自动剪枝，而非手动删除。
