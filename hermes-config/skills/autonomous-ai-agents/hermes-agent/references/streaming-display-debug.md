# Streaming Display — Debugging Path

## Discovery Session

This document captures the debugging path from a session where the user reported that the agent's output appeared "all at once after a long wait" rather than streaming token-by-token. The user explicitly asked: "你可以流式输出你的思考过程和回答吗？不要等一段时间后，一下子全部输出出来。"

## Symptoms

- Long pause between user message and response appearing
- When response finally appears, it's a large wall of text
- User perceives the agent as "slow" or "waiting and then dumping everything"
- No visual feedback during generation

## Root Cause

The config key `display.streaming` was set to `false` in `~/.hermes/config.yaml`:

```yaml
display:
  streaming: false  # ← This buffers the entire response before rendering
```

When `streaming` is `false`, the Hermes CLI waits for the LLM to complete the entire turn (including all tool call rounds) before rendering any output to the terminal. The user sees nothing during generation, then gets the complete response at once.

## Correct Debugging Path

```
1. Suspect display config (not model/provider latency)
2. Check ~/.hermes/config.yaml, look under 'display:' section
3. Found: streaming: false
4. Confirm: grep -A 10 "display:" ~/.hermes/config.yaml
5. Fix: hermes config set display.streaming true + /reset
```

## Key Lesson

When a user reports output appearing "all at once" or "after a long wait", check `display.streaming` first — not the provider latency or model speed. The streaming config affects _rendering_ timing, not generation timing.

## Distinguishing from Other Issues

| Symptom | Likely cause | Check |
|---------|-------------|-------|
| Long pause, then all text appears at once | `display.streaming: false` | config.yaml |
| Text streams but very slowly between tokens | Provider/model latency | Change provider or model |
| Text streams but thinking never shows | `display.show_reasoning: false` | config.yaml |
| Text appears, then disappears/re-renders | TUI rendering issue | Check skin/footer settings |
