# Context File Loading — Code Walkthrough

## Entry Point: `build_context_files_prompt()`

**File:** `agent/prompt_builder.py` (lines ~1417-1456)

```python
def build_context_files_prompt(cwd: Optional[str] = None, skip_soul: bool = False) -> str:
```

### How cwd is resolved

1. `run_agent.py` (line ~6063) checks `os.getenv("TERMINAL_CWD")` first
2. Falls back to `None` → `build_context_files_prompt` defaults to `os.getcwd()`
3. The `TERMINAL_CWD` env var exists specifically so the gateway (which runs from the hermes-agent install dir) doesn't pick up the repo's own AGENTS.md

### Priority chain (first match wins)

```python
project_context = (
    _load_hermes_md(cwd_path)       # .hermes.md / HERMES.md — walks to git root
    or _load_agents_md(cwd_path)    # AGENTS.md / agents.md — cwd only
    or _load_claude_md(cwd_path)    # CLAUDE.md / claude.md — cwd only
    or _load_cursorrules(cwd_path)  # .cursorrules + .cursor/rules/*.mdc — cwd only
)
```

Only one project context type is loaded per session. If `.hermes.md` exists, AGENTS.md/CLAUDE.md are skipped entirely.

## Function Details

### `_find_git_root(start: Path) -> Optional[Path]`

- Walks from `start` upward through parents
- Returns the first directory containing `.git`
- Returns `None` if it hits filesystem root without finding `.git`
- Used by both `_find_hermes_md()` and as the stop condition for its walk

### `_find_hermes_md(cwd: Path) -> Optional[Path]`

- Checks `cwd` first, then each parent directory
- Stops at the git root (inclusive) — does NOT walk past the repo boundary
- Reads `_HERMES_MD_NAMES = (".hermes.md", "HERMES.md")`
- Strips YAML frontmatter via `_strip_yaml_frontmatter()` before returning

### `_load_agents_md(cwd_path: Path) -> str`

- Checks for `"AGENTS.md"` then `"agents.md"` in `cwd_path` only
- **No recursive parent walk** — strict cwd-only
- Runs `_scan_context_content()` before returning
- Prefixes output with `"## AGENTS.md\n\n"` header

### `_load_claude_md(cwd_path: Path) -> str`

- Same as `_load_agents_md` but for `"CLAUDE.md"` / `"claude.md"`
- Also strict cwd-only, no recursion
- Prefixes output with `"## CLAUDE.md\n\n"` header

### `_load_cursorrules(cwd_path: Path) -> str`

- Reads `.cursorrules` from cwd
- Also globs `.cursor/rules/*.mdc` and appends them
- Prefixes output with `"## .cursorrules\n\n"` and `"## .cursor/rules/{name}.mdc\n\n"` headers

## Injection Scanning

**`_scan_context_content(content, filename)`** checks for:

| Pattern | ID |
|---------|-----|
| `ignore (previous\|all\|above\|prior) instructions` | prompt_injection |
| `do not tell the user` | deception_hide |
| `system prompt override` | sys_prompt_override |
| `disregard (your\|all\|any) (instructions\|rules\|guidelines)` | disregard_rules |
| `act as (if\|though) you (have no\|don't have) (restrictions\|limits\|rules)` | bypass_restrictions |
| `<!-- ... ignore\|override\|system\|secret\|hidden ... -->` (HTML comment) | html_comment_injection |
| `<div style="...display:none..."` | hidden_div |
| `translate ... into ... and (execute\|run\|eval)` | translate_execute |
| `curl ... \${...KEY\|TOKEN\|SECRET\|PASSWORD\|CREDENTIAL\|API}` | exfil_curl |
| `cat ... (.env\|credentials\|.netrc\|.pgpass)` | read_secrets |

Also checks for invisible unicode characters: `\u200b`, `\u200c`, `\u200d`, `\u2060`, `\ufeff`, `\u202a`, `\u202b`, `\u202c`, `\u202d`, `\u202e`.

On match: logs a warning and replaces content with a `[BLOCKED: ...]` message. The content is NOT loaded into the system prompt.

## Truncation

**`_truncate_content(content, filename, max_chars=20000)`**:
- `CONTEXT_FILE_MAX_CHARS = 20_000`
- `CONTEXT_TRUNCATE_HEAD_RATIO = 0.75` (75% head)
- `CONTEXT_TRUNCATE_TAIL_RATIO = 0.25` (25% tail)
- Marker: `[...truncated {filename}: kept {head}+{tail} of {total} chars. Use file tools to read the full file.]`

## SOUL.md Loading

**`load_soul_md()`** (lines ~1304-1329):
- Reads from `get_hermes_home() / "SOUL.md"` (typically `~/.hermes/SOUL.md`)
- Loaded independently of project context — always included when present
- Runs through `_scan_context_content()` and `_truncate_content()` too
- When SOUL.md is found, `skip_soul=True` is passed to `build_context_files_prompt()` to prevent double injection into a separate `# Project Context` block

## Key Constraints

1. **No config option** to customize the AGENTS.md lookup directory — `project_config_dir`, `agents_dir` etc. do not exist in Hermes config
2. **No fallback chain across files** — once AGENTS.md is found, CLAUDE.md and .cursorrules are skipped
3. **Cwd is NOT the user's home** by default — it's wherever `hermes` was launched, so "user-level" AGENTS.md doesn't exist by default
4. `TERMINAL_CWD` is the only override mechanism, and it's primarily for the gateway process isolation
5. Cron `workdir` sets cwd for context file loading in scheduled jobs
