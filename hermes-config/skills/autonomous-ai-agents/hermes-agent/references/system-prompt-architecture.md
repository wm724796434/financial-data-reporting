# System Prompt Architecture

> How Hermes assembles the system prompt: three tiers, cache strategy, and the memory snapshot pattern.
> Created: 2026-05-19 during a deep-dive session prompted by user questions about token waste and memory management.

## Three-Tier Architecture

The system prompt is split into three ordered tiers, each with a different cache lifetime. Defined in `run_agent.py::_build_system_prompt_parts()`:

```
┌─────────────────────────────────────────────────────┐
│ 稳定层 (stable) — never changes mid-session          │
│  ├── SOUL.md (or DEFAULT_AGENT_IDENTITY)  → slot #1 │
│  ├── Tool guidance blocks (memory/session_search/    │
│  │   skills/kanban) — gated by valid_tool_names      │
│  ├── Skills index (names + descriptions + triggers)  │
│  ├── Environment hints (WSL, Termux, etc.)           │
│  ├── Platform hints (WeChat/Telegram/CLI behavior)   │
│  └── Model-family operational guidance (Gemini/GPT)  │
├─────────────────────────────────────────────────────┤
│ 上下文层 (context) — stable per working directory     │
│  ├── Caller-injected system_message (if any)          │
│  └── Project context (one of these, priority order):  │
│      .hermes.md > AGENTS.md > CLAUDE.md > .cursorrules│
├─────────────────────────────────────────────────────┤
│ 易失层 (volatile) — rebuilt every session             │
│  ├── MEMORY.md frozen snapshot                        │
│  ├── USER.md frozen snapshot                           │
│  ├── External memory provider block (if configured)   │
│  └── Timestamp + Session ID + Model/Provider info     │
└─────────────────────────────────────────────────────┘
```

## Caching Strategy (Prefix Cache Optimization)

**The entire system prompt is assembled ONCE per session** and cached on `self._cached_system_prompt`. It is only rebuilt after context compression events (`compress_context` triggers a rebuild). The three-tier design serves a single goal: **keep the upstream LLM provider's prompt cache warm across every turn in the session.**

Implementation point: `_build_system_prompt()` (run_agent.py ~line 6109) joins the three tiers and caches the result. Every subsequent turn reads the cached string — Hermes never rebuilds or re-injects parts of the system prompt mid-session.

### Frozen Snapshot Pattern

The `MemoryStore` class (`tools/memory_tool.py`) maintains TWO parallel states:

| State | What | When created | Mutated? |
|-------|------|-------------|----------|
| `_system_prompt_snapshot` | Frozen copy of entries at load time | `load_from_disk()` | NO — never mutated |
| `memory_entries` / `user_entries` | Live list | `load_from_disk()` | YES — by `memory()` tool calls |

- `format_for_system_prompt(target)` always returns the **frozen snapshot**, not live state
- Live mutations (add/replace/remove) update the in-memory list + write to disk — but the system prompt snapshot stays unchanged
- The model learns about new memories via **tool call results** (the return value of `memory(action='add')` includes the full updated list)

Why? If every memory write required rebuilding the system prompt, the prompt cache would be invalidated on every write — negating the entire caching benefit.

## Context Compression Algorithm

Defined in `agent/context_compressor.py::ContextCompressor`. Triggered when prompt tokens exceed 50% of model context length (configurable via `compression.threshold`).

**5 phases:**

1. **Prune old tool results** (LLM-free): Replace old terminal/read_file/search results with 1-line summaries like `[terminal] ran npm test -> exit 0, 47 lines output`. Also deduplicates identical tool results (keeps newest copy).

2. **Boundary protection**: 
   - Head: protect system prompt + first exchange (configurable `protect_first_n=3`)
   - Tail: protect most recent ~20K tokens by budget (`tail_token_budget`), not by message count

3. **LLM summarization**: Send middle turns to the LLM with a structured prompt template that tracks:
   - Completed items
   - Pending/resolved questions
   - Latest active focus

4. **Assembly**: Head + summary + tail. Summary is inserted with clear END marker (`--- END OF CONTEXT SUMMARY — respond to the message below, not the summary above ---`) to prevent the model from treating the summary as new user input.

5. **Iterative updates**: On re-compression, the previous summary is found and updated — not regenerated from scratch. This prevents summary size from growing unboundedly across multiple compressions.

**Anti-thrashing**: If 2 consecutive compressions each save <10%, compression is paused. The agent receives a hint to `/new` or `/compress <topic>`.

**Focus topic compression** (`/compact <topic>`): When a topic string is provided, the summarizer prioritizes preserving information about that topic and compresses other content more aggressively.

## Context File Loading Priority

Defined in `agent/prompt_builder.py::build_context_files_prompt()`. Priority (first match wins — only ONE project context type loaded):

| Type | Search scope | Priority |
|------|-------------|----------|
| `.hermes.md` / `HERMES.md` | cwd → git root walk | 1st |
| `AGENTS.md` / `agents.md` | cwd only | 2nd |
| `CLAUDE.md` / `claude.md` | cwd only | 3rd |
| `.cursorrules` + `.cursor/rules/*.mdc` | cwd only | 4th |

SOUL.md (`~/.hermes/SOUL.md`) is independent — always loaded (goes into identity slot #1 in stable tier). When `load_soul_md()` returns content, `skip_soul=True` is passed to `build_context_files_prompt()` to prevent double injection.

TERMINAL_CWD env var overrides the directory used for context file discovery (prevents gateway process from loading the Hermes repo's own AGENTS.md).

Each source is capped at 20,000 chars with head/tail truncation (75% head, 25% tail by default).

## Memory File Locations & Limits

| File | Path | Default limit |
|------|------|-------------|
| MEMORY.md | `~/.hermes/memories/MEMORY.md` | 2,200 chars |
| USER.md | `~/.hermes/memories/USER.md` | 1,375 chars |
| SOUL.md | `~/.hermes/SOUL.md` | 21KB truncation |
| AGENTS.md | `$CWD/AGENTS.md` | 20,000 chars |

Memory entries are separated by `§` (section sign) delimiter. Deduplication preserves first occurrence.

## Topic / Thread Concept

In gateway context, `topic` maps to `thread_id` in session routing (`gateway/session.py`). The session key construction is:

```
DM session:    agent:main:{platform}:dm:{chat_id}
With thread:   agent:main:{platform}:dm:{chat_id}:{thread_id}
```

Weixin (WeChat) is single-thread — no `thread_id`. Topic concept primarily applies to platforms with thread/sub-topic support (Telegram Topics, Discord Threads, forum channels).

The `topic` slash command (`/topic`) in gateway enables or inspects Telegram DM topic sessions.

## Key Design Tradeoffs

| Design decision | Benefit | Cost |
|----------------|---------|------|
| System prompt cached once | Prefix cache hits every turn | Memory writes don't update system prompt |
| Memory snapshot frozen at load | No cache invalidation on writes | Model learns new memory only via tool results |
| 50% compression threshold | Prevents premature compression | Some sessions reach threshold before meaningful work |
| Head/tail protection during compression | Recent context always preserved | Middle turns lost (summarized) |
| One project context file (not all) | Predictable source of truth | User may expect multiple files loaded |
