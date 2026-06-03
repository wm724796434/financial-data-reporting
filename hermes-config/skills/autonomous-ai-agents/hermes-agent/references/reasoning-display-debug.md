# Reasoning/Thinking Tag Display — Debugging Path

## Discovery Session

This document captures the debugging path from a real session where the user reported that the agent's `<thinking>` reasoning content wasn't visible in the CLI terminal.

## Symptoms

- User could not see any thinking/reasoning text from the agent
- Agent confirmed it **was** writing `<thinking>` blocks, but they weren't rendered
- The issue was consistent across questions, not intermittent

## Root Cause

The config key `display.show_reasoning` was set to `false` in `~/.hermes/config.yaml`:

```yaml
display:
  show_reasoning: false  # ← This filters <thinking> tags from CLI output
```

When `show_reasoning` is `false`, the Hermes CLI rendering layer strips all `<thinking>` content before displaying the response. The agent continues to produce thinking tags as part of its normal output protocol, but the user never sees them.

## Initial (Wrong) Approach

The agent initially tried to work around the problem by changing its own output format — putting reasoning in plain text instead of `<thinking>` tags. This was incorrect because:

1. It broke the structural separation between reasoning and response
2. The fix was session-local (next session would revert)
3. It didn't address the underlying config issue
4. The user explicitly redirected to find the root cause instead

## Correct Debugging Path

```
1. Suspect display filter (not agent behavior)
2. Read ~/.hermes/config.yaml, look under 'display:' section
3. Found: show_reasoning: false
4. Confirm: grep -A 10 "display:" ~/.hermes/config.yaml
5. Fix options:
   a. Temporary (/reasoning show or /reasoning high via slash command)
   b. Permanent (hermes config set display.show_reasoning true + /reset)
```

## Key Lesson

When a CLI rendering issue appears, **check display config first** — don't ask the agent to reformat its output. The agent's output format is determined by the system prompt protocol, not by the rendering layer. Working around a display filter with output format changes is a symptom fix, not a root cause fix.

## Related Config

| Config key | Default | Effect |
|-----------|---------|--------|
| `display.show_reasoning` | `false` | When false, `<thinking>` tags are stripped from CLI output |
| `display.streaming` | `false` | Whether responses stream token-by-token |
| `display.timestamps` | `false` | Whether each message shows a timestamp |

See `display` section in config.yaml for the full list.
