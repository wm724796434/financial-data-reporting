# Hermes Memory & User Profile Management

## Stores

Hermes has two persistent memory stores, injected at every new session start:

| Store | Config Key | Default Limit | Content |
|-------|-----------|---------------|---------|
| `memory` | `memory_char_limit` | 2200 chars | Environment facts, tool quirks, project conventions, lessons learned |
| `user` | `user_char_limit` | 1375 chars | User identity, preferences, behavioral rules, stable personal details |

Configure limits via:
```bash
hermes config set memory.memory_char_limit 5000
hermes config set memory.user_char_limit 3000
# requires /reset to take effect
```

## Injection Mechanism

- Injected at **session start** into the system prompt preamble (top of context, benefiting from "primacy effect" in lost-in-the-middle research)
- NOT re-injected mid-session on subsequent turns
- Both stores injected as a flat list of entries, not a single blob — each entry retains its separate identity
- Entry order is insertion order (not re-sorted)
- Third-party backends (Honcho, Mem0) can replace the built-in flat-store with semantic retrieval — only injects relevant fragments

## Design Rules

### Cross-project vs project-specific content

- `user` store is **global** — applies to all projects. Must not contain project-specific paths, conventions, or rules.
- `memory` store is also **global** — same constraint.
- Project-specific rules (AGENTS.md query flow, ClaudeCode-main not editable) belong in:
  - Project context files (AGENTS.md / CLAUDE.md / .hermes.md) — auto-loaded per directory
  - Skills — loaded per task class

### Storage strategy

- One dense entry per theme (not many small entries) — saves slot-space in the char limit
- Merge related preferences into one entry to avoid fragmentation
- Prune/merge when approaching the char limit; stale entries that no longer reflect user preferences should be replaced

## Capacity Concerns

- Expanding limits increases system prompt size, raising token cost per session
- Longer injected content risks "lost in the middle" attention dilution — content at top (primacy) and bottom (recency) of the injected block has best recall
- If user + memory exceed ~3000 chars combined, consider whether some content should move to a skill instead (skills are loaded on-demand, not every session)
