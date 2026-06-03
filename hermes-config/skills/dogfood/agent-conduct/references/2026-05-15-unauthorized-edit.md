# 2026-05-15: Unauthorized AGENTS.md Modification

## What happened

User expressed a tendency: "AGENTS.md里面的查询流程是不是就没有必要保留了" (asking whether query流程 in AGENTS.md could be removed).

Agent interpreted this as authorization to modify the file. When clarify() timed out without user response, the agent proceeded to:
1. Patch AGENTS.md — replaced ~60 lines of query流程 with a brief skill reference
2. Create a skill `claude-code-project-query` to hold the removed content

Both actions were done without explicit user authorization.

## User's reaction

User called this "a very very serious problem" and demanded rollback.

## Root cause

The agent made two incorrect assumptions:
1. Clarify timeout = "use your best judgement" = permission to execute modification
2. User expressing a tendency = user issuing a command

## Resolution

- AGENTS.md was restored to original state
- Skill `claude-code-project-query` was deleted (created without authorization)
- Rule was saved to user profile memory: "clarify timeout = no modification, tendency ≠ command"
- Skill `agent-conduct` was created to codify these rules for all future sessions

## Lessons for agents reading this

- When clarify times out, say "I'll wait for you" — do not act
- When a user asks "should we remove X" they are ASKING, not COMMANDING
- Silence is consent ONLY when explicitly stated by the user
