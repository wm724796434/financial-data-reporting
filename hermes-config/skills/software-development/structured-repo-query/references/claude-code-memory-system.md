# Claude Code Memory System — Worked Example

> Session: 2026-05-15 — This file documents the real findings from properly querying the Claude Code 源码解析 repository. It serves as a concrete example of what the structured-repo-query skill prevents.

## The Mistake

**Question**: "Does Claude Code have a memory module?"

**Wrong approach** (what actually happened):
1. Ran `search_files` on `ClaudeCode-main/` with pattern `memory|memory_manager|memory_provider|persistent_memory` targeting filenames
2. Got 0 results
3. **Concluded**: "Claude Code has no memory system" ❌

**Why it failed**:
- The directory is named `memdir/` not `memory/`
- The `SessionMemory/` path didn't match the search
- The protocol file (`综合/功能模块映射.md`) was never consulted — it explicitly lists "记忆系统" as a module
- No index check was done before searching

## The Correct Approach

**Follow the AGENTS.md query flow (场景A)**:
1. Read `综合/功能模块映射.md` → Found "记忆系统" module with 18+ files across 4 directories
2. Read `综合/源码清单.md` → Found `commands/memory/` listing
3. Listed files in `memdir/`, `services/SessionMemory/`, `services/extractMemories/`, `services/teamMemorySync/`
4. Read header blocks of core files to verify

## What Was Found

### Module Structure (18+ files)

```
ClaudeCode-main/
├── memdir/                          # Core memory directory (8 files)
│   ├── memdir.ts                    # Main logic: MEMORY.md entry point management
│   ├── memoryTypes.ts               # Memory type taxonomy (4 types) + prompt templates
│   ├── findRelevantMemories.ts      # Sonnet-based relevant memory retrieval
│   ├── memoryScan.ts                # Memory file manifest scanning
│   ├── memoryAge.ts                 # Memory age management
│   ├── paths.ts                     # Memory path management
│   ├── teamMemPaths.ts              # Team memory paths
│   └── teamMemPrompts.ts            # Team memory prompts
│
├── services/SessionMemory/          # In-session memory (3 files)
│   ├── sessionMemory.ts             # Background forked agent maintains session notes
│   ├── sessionMemoryUtils.ts        # Utility functions
│   └── prompts.ts                   # Prompt templates
│
├── services/extractMemories/        # Auto memory extraction (2 files)
│   ├── extractMemories.ts           # Post-session durable memory extraction
│   └── prompts.ts                   # Prompt templates
│
├── services/teamMemorySync/         # Team memory sync (5 files)
│   ├── index.ts                     # Core logic (44KB!)
│   ├── watcher.ts                   # File watcher
│   ├── secretScanner.ts             # Sensitive info scanner
│   ├── teamMemSecretGuard.ts        # Secret guard
│   └── types.ts                     # Type definitions
│
└── commands/memory/                 # CLI commands
    ├── memory.tsx
    └── index.ts
```

### Core Design Principles (from `memoryTypes.ts`)

> **Only store what CANNOT be derived from the current project state.** Code patterns, architecture, git history, and file structure are derivable (via grep/git/CLAUDE.md) and should NOT be saved as memories.

### Memory Type Taxonomy

| Type | Scope | Description |
|------|-------|-------------|
| `user` | always private | User role, goals, responsibilities, knowledge, preferences |
| `feedback` | private or team | User evaluations and feedback on past work |
| `project` | private or team | Project-level durable information |
| `reference` | private or team | Reference materials, API docs, gotchas |

### Key Parameters (from `memdir.ts`)

- `MAX_ENTRYPOINT_LINES = 200` — MEMORY.md entry point capped at 200 lines
- `MAX_ENTRYPOINT_BYTES = 25_000` — ~125 chars/line, catches long-line indexes
- `findRelevantMemories()`: Sonnet selects up to 5 relevant memories per query turn

### Sub-Module Behaviors

| Module | Trigger | Mechanism |
|--------|---------|-----------|
| `memdir/` | Each query turn | MEMORY.md injected into system prompt; Sonnet selects additional relevant memories |
| `extractMemories/` | End of each complete query loop | Forked agent extracts durable info from session transcript |
| `SessionMemory/` | Periodically during conversation | Background forked agent maintains current session notes |
| `teamMemorySync/` | File changes + sync events | File watcher + secret scanner for team-level memory sharing |

## Takeaway

The index (`综合/功能模块映射.md`) explicitly listed ClCode's memory system with 18 files across 4 directories. Skipping it led to a confidently wrong answer. Following it revealed a complete, well-designed memory architecture.
