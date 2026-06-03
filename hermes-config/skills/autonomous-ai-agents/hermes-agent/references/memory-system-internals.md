# Memory System Internals

> Memory subsystem: configuration knobs, injection behavior, capacity limits, and tradeoffs.
> Created: 2026-05-15 during a deep-dive session on memory mechanism.

## Storage Architecture

Hermes Agent has two separate memory stores, both file-backed:

| Store | Config key | Default limit | Purpose |
|-------|-----------|---------------|---------|
| `memory` | `memory_char_limit` | 2,200 chars | Environment facts, tool quirks, project conventions |
| `user` | `user_char_limit` | 1,375 chars | User profile — preferences, corrections, behavioral rules |

## Configuration

View and modify limits:

```bash
# Check current values
grep -A 5 'memory:' ~/.hermes/config.yaml

# Expand capacity
hermes config set memory.memory_char_limit 5000
hermes config set memory.user_char_limit 3000
```

Other memory config keys:
- `memory_enabled: true` — master toggle
- `user_profile_enabled: true` — master toggle for user store
- `provider: ''` — empty = built-in file storage; set to `honcho`, `mem0`, etc. for vector-db backends

Changes take effect on next session (`/reset` or restart).

## Injection Behavior

Memory is injected into the **system prompt at session start only**, not per-turn:

- All entries from both stores are concatenated into a single block at the top of the system prompt
- Does **not** re-inject mid-session (preserves prompt caching)
- On `/reset` (new session), memory is re-read and re-injected

## Audit Trail

Every `memory(target='user')` call produces an automatic log line visible in the CLI output:

```
Self-improvement review: User profile updated
```

This is Hermes framework-level logging, not controllable by the agent. It serves as an audit trail — the user can see whenever the agent modifies their profile.

`memory(target='memory')` does NOT produce this log line (only `target='user'` triggers it).

## Capacity Tradeoffs

Expanding `memory_char_limit` or `user_char_limit` has costs:

1. **Token cost per session** — all content is injected every session. Doubling capacity roughly doubles the input token overhead from memory.
2. **Attention dilution (Lost in the Middle)** — LLMs recall information at the beginning and end of long contexts far better than the middle. Memory sits at the very start of the system prompt (best position), but as total system prompt grows (memory + project context + SOUL.md + skills), even the start position's advantage erodes. More entries also means the model must pick from a larger set, increasing the chance of missing a specific rule among many.
3. **Compression pressure** — larger memory consumes more of the context window budget, potentially triggering compression earlier.

**Recommendation:** Keep memory concise and focused on stable user preferences, not task state. Use skills (loaded on demand) for procedural knowledge that doesn't need to be visible every session.

## External Memory Backends

The `provider` setting enables alternative backends (requires plugin installation):

```bash
hermes memory setup    # Interactive: configure Honcho, Mem0, or SuperMemory
```

External backends use vector search to inject only the most relevant memory fragments each session, avoiding the "dump everything" approach of the built-in store. This allows larger total memory without proportional token cost — but adds a service dependency and latency on memory retrieval.

## No Automatic Learning

The agent does not autonomously update memory. Every memory write is:
1. A deliberate tool call (`memory(action='add'|'replace'|'remove')`)
2. Made when the agent judges a fact will be useful across sessions
3. Visible to the user via the self-improvement audit log

There is no background scanning, no conversation mining, and no scheduled profile updates.
