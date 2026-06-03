# OpenCode vs Hermes：存储与记忆架构对比

本文件记录了 Hermes Agent 与 OpenCode 在会话存储、跨会话记忆和上下文管理上的架构差异。基于对两者 SQLite 数据库的实际逆向工程（2026-05-21）。

---

## 一、概览

| 维度 | Hermes | OpenCode |
|------|--------|----------|
| 数据库 | SQLite — `~/.hermes/state.db` | SQLite — `~/.local/share/opencode/opencode.db` (Win) |
| 典型大小 | ~28 MB | ~22 MB |
| 消息数 | ~1,900 | ~1,270 |
| 会话数 | ~30 | ~75 |
| 跨会话搜索 | ✅ FTS5 全文检索 | ❌ 无 |
| 上下文管理 | 压缩 + session_search | Compaction agent |
| 保留策略 | `retention_days: 90`, `auto_prune: false` | 无显式保留策略 |
| agent 体系 | 单 agent 主循环 | 多 agent：build/plan/compaction/summary/title/explore |

---

## 二、Hermes：FTS5 全文检索（session_search）

### 核心表

```sql
-- sessions (30 rows)
CREATE TABLE sessions (
    id TEXT PRIMARY KEY,
    source TEXT,         -- cli, telegram, discord...
    started_at REAL,
    ended_at REAL,
    message_count INTEGER,
    tool_call_count INTEGER,
    input_tokens INTEGER, output_tokens INTEGER,
    title TEXT,
    ...
);

-- messages (~1900 rows)
CREATE TABLE messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT REFERENCES sessions(id),
    role TEXT,                    -- user / assistant / tool
    content TEXT,                 -- 消息正文（完整存储）
    tool_calls TEXT,              -- 工具调用完整JSON
    reasoning TEXT,               -- thinking 标签内容
    token_count INTEGER,
    timestamp REAL,
    ...
);
```

### FTS5 双重索引

Hermes 为 `messages.content` 建了两套 FTS5 虚拟表：

**标准索引（messages_fts）：**
```sql
CREATE VIRTUAL TABLE messages_fts USING fts5(content);
```
按空格/标点切词。英文表现良好；中文极差（无空格整句被视为一个 token）。

**Trigram 索引（messages_fts_trigram）：**
```sql
CREATE VIRTUAL TABLE messages_fts_trigram USING fts5(
    content,
    tokenize='trigram'
);
```
切成三字连续子串（n-gram）。例如 `"虚坛战一场"` → `"虚坛"` `"坛战"` `"战一"` `"一场"`。
**这是中文可搜的关键**：不需要中文分词词典，任意子串都能命中。
代价：索引体积约为标准 FTS5 的 5 倍。

### 搜索流程

1. 查询参数传入 FTS5 trigram 索引
2. 同样切成 trigram 匹配
3. 查询词通过 `OR` 隐式连接
4. 匹配的 message_id → session_id
5. 对每个匹配会话，用 LLM 生成摘要
6. 返回摘要列表（上限 5 条）

每次调用成本 = 匹配数 × 一次 LLM 摘要调用。

### 保留策略

```yaml
sessions:
  auto_prune: false          # 默认不清理
  retention_days: 90         # 策略上限
  vacuum_after_prune: true
  min_interval_hours: 24
```

`auto_prune: false` 意味着**所有对话永久保留**，数据库无限增长（仅受磁盘限制）。

---

## 三、OpenCode：Session Compaction（会话压缩）

### 核心表

```sql
-- session (75 rows, 28个字段)
CREATE TABLE session (
    id TEXT PRIMARY KEY,
    project_id TEXT,         -- 所属项目
    parent_id TEXT,          -- 分支/派生关系
    slug TEXT,
    directory TEXT,
    title TEXT,
    version TEXT,
    summary_additions INTEGER,     -- 摘要：新增代码行
    summary_deletions INTEGER,     -- 摘要：删除代码行
    summary_files INTEGER,         -- 摘要：修改文件数
    summary_diffs TEXT,            -- 摘要：diff 文本
    revert TEXT,                   -- 回滚状态
    permission TEXT,
    time_created INTEGER,
    time_compacting INTEGER,       -- 最近压实的时间戳
    time_archived INTEGER,         -- 归档时间戳
    workspace_id TEXT,
    path TEXT,
    agent TEXT,                    -- build / plan 等
    model TEXT,
    cost REAL,
    tokens_input INTEGER, tokens_output INTEGER,
    tokens_reasoning INTEGER, tokens_cache_read INTEGER,
    tokens_cache_write INTEGER,
    ...
);

-- message (1271 rows)
CREATE TABLE message (
    id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL REFERENCES session(id),
    time_created INTEGER,
    time_updated INTEGER,
    data TEXT NOT NULL       -- JSON: {role, time, agent, model, summary: {diffs: []}}
);

-- part (6131 rows)
CREATE TABLE part (
    id TEXT PRIMARY KEY,
    message_id TEXT NOT NULL REFERENCES message(id),
    session_id TEXT NOT NULL,
    time_created INTEGER,
    time_updated INTEGER,
    data TEXT NOT NULL       -- JSON: {type: "text", text: "你好"}
);
```

关键发现：
- **message** 仅存元数据（JSON），实际消息内容在 **part** 表中（一条消息含多个 part）
- **无 FTS5 虚拟表** — 没有全文检索
- **无 memory/rag/recall/knowledge/context 相关表**
- `summary_*` 字段表明压实后的结果存储在 session 级别
- `time_compacting` 作为压实时间戳

### Compaction 机制

OpenCode 有一个专门的 **`compaction`** agent（从 `opencode agent list` 可见）。其职责：

1. 检测到会话消息过多（超过某个未公开的阈值）
2. compaction agent 读取当前会话的所有 message + part
3. 用 LLM 生成会话摘要（改了哪些文件、讨论了什么）
4. 摘要写入 `session.summary_*` 字段
5. 后续轮次只带摘要 + 最近几轮消息进上下文

**这不是跨会话搜索**，而是单会话内的上下文窗口管理。设计哲学是 "太长了就压缩掉"。

### 其他 agent

OpenCode 有多 agent 架构，每个 agent 有独立的权限配置：
- **build** — 主编程 agent（读写文件权限最广）
- **plan** — 计划 agent（只读 + 写计划文件）
- **compaction** — 压缩/压实 agent
- **summary** — 生成会话摘要
- **title** — 自动生成会话标题
- **explore** — 文件探索子 agent（只读 + grep + web）
- **general** — 通用子 agent

权限以 `[{permission, action, pattern}]` 列表管理，支持 allow/ask/deny。

---

## 四、架构哲学对比

### 记忆方案

| | Hermes | OpenCode |
|--|--------|----------|
| 设计口号 | **"全都记着，随时翻"** | **"记不住了就压缩"** |
| 跨会话回溯 | ✅ session_search | ❌ 无 |
| 上下文管理 | 压缩 + 定时清除 | compaction agent 压实 |
| 用户可控搜索 | 有专用命令 | 无 |
| 中文搜索 | 好（trigram） | 不适用 |

### 适用场景

**Hermes session_search 适合**：
- 需要跨多个会话找回历史讨论内容
- 用户经常问"我们之前聊过X吗"
- 需要浏览式回溯而非精确打开旧会话

**OpenCode compaction 适合**：
- 专注于单个项目的长对话
- 每个会话相对独立，不需要跨会话检索
- 会话之间靠 git/worktree 隔离，而非搜索

### 三层存储模型（Hermes 特有）

Hermes 有三种跨会话信息保留机制：

| 层 | 范围 | 延迟 | 用途 |
|---|------|------|------|
| **memory** | 短事实条目 | 零（自动注入） | 高频指引 |
| **longterm.md** | 完整内容 | 按需读取 | 人为策划的重要备忘 |
| **session_search** | 所有原始对话 | 中等（搜索+摘要） | 不需要预先策划的全量回溯 |

OpenCode 没有对应的三层模型——它只有 compaction 一种机制。

---

## 五、调测技巧

如果需要自己探索 agent 内部存储：

```python
import sqlite3

# Hermes
conn = sqlite3.connect(os.path.expanduser('~/.hermes/state.db'))
cur = conn.cursor()
cur.execute("SELECT name FROM sqlite_master WHERE type='table'")
print(cur.fetchall())

# OpenCode (Windows)
conn = sqlite3.connect('/mnt/c/Users/wm/.local/share/opencode/opencode.db')
```

查看索引类型：
```python
cur.execute("SELECT name FROM sqlite_master WHERE type='index' OR type='virtual'")
```

查看 schema：
```python
cur.execute("SELECT sql FROM sqlite_master WHERE name='message'")
```

> ⚠️ **注意**：OpenCode 的数据库位于 Windows 文件系统（`%LOCALAPPDATA%\opencode\opencode.db`），在 WSL 中通过 `/mnt/c/Users/<user>/.local/share/opencode/opencode.db` 访问。Hermes 的 state.db 始终在 `~/.hermes/` 下。

---

## 六、历史与背景

- 本文件创作的触发场景：用户问"opencode有没有类似的记忆模块，他的rag跟这个是一样的功能吗"，从而驱动了对 OpenCode 数据库的完整逆向。
- 用户对 session_search 的追溯能力给出了一个具体用例：在一周前的对话中助手的"误读→被纠正"这一细节，没有写入任何持久存储，却通过 session_search 被回溯出来。详见 session-search-architecture.md 的三层存储模型说明。
