# Verifying Model Capabilities — Worked Example

## Context

Session demonstrating how to verify whether a specific AI model exists and whether it supports vision (image recognition). The user asked: "DeepSeek-V4-Pro是否是视觉模型" and corrected the agent for assuming the model didn't exist based on training data alone.

## Steps Taken

### 1. Identify the provider's official API docs

DeepSeek's official API docs are at `https://api-docs.deepseek.com/`. This is where the authoritative model list lives.

### 2. Scrape the quick-start page for model names

```bash
curl -sL --max-time 10 "https://api-docs.deepseek.com/" 2>/dev/null
```

The page contains a parameter table listing valid `model` values:

| model | description |
|-------|-------------|
| `deepseek-v4-flash` | Current gen fast model |
| `deepseek-v4-pro` | Current gen pro model |
| `deepseek-chat` | Deprecated (maps to flash non-thinking) |
| `deepseek-reasoner` | Deprecated (maps to flash thinking) |

### 3. Scrape the pricing page for feature support

```bash
curl -sL --max-time 10 "https://api-docs.deepseek.com/quick_start/pricing" 2>/dev/null
```

The pricing page's Features table shows:

| Feature | deepseek-v4-flash | deepseek-v4-pro |
|---------|------------------|-----------------|
| JSON Output | ✓ | ✓ |
| Tool Calls | ✓ | ✓ |
| Chat Prefix Completion | ✓ | ✓ |
| FIM Completion | Non-thinking only | Non-thinking only |
| Context Length | 1M | 1M |
| Max Output | 384K | 384K |

**No "Vision" or "Image" feature listed** → verified: deepseek-v4-pro is NOT a vision model.

### 4. Cross-reference

The model exists (confirmed on quick-start page) but has no vision capability (confirmed by missing from pricing features). Final answer: "Exists but text-only, no image recognition."

## Why This Matters

- **Training data is stale** — model lineups (especially from Chinese providers like DeepSeek, Qwen, GLM) evolve between training data cutoffs. "I don't know about model X" is honest but incomplete; "I'll verify" is the correct response.
- **Official API docs are the source of truth** — not blog posts, not Twitter/X announcements, not news articles. Provider docs list actual `model` parameter values you can use.
- **Feature tables tell you what the model can do** — if vision isn't in the feature grid, the model doesn't support it, regardless of model size or generation number.

## Curl Notes

- `-sL` = silent + follow redirects
- `--max-time 10` = timeout after 10 seconds
- The API docs pages are typically rendered as static HTML (Docusaurus) — grep/sed/python for text extraction works
- DuckDuckGo's API (`api.duckduckgo.com`) and lite search (`lite.duckduckgo.com`) are fallbacks if you don't know the provider's site URL, but less reliable than direct scraping of official docs

## Pitfalls

- **DuckDuckGo API returns empty** on many queries — don't rely on it as primary search
- **curl to python3 pipe** gets flagged by security scanning — use `head -100` or `grep` for initial inspection to reduce false positive alerts
- **Some docs are client-rendered** (React/Svelte) — inspect the raw HTML response before parsing; if it's mostly JavaScript, try a different endpoint or use a headless browser tool
