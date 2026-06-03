# File Content Forensic Analysis — Worked Examples

## Example: Embedded Line Numbers in Markdown

### Scenario

User says: "AGENTS.md format has issues — the `#`, `##`, `###` heading markers aren't working."

### The Wrong Approach (what happened first)

Assume it's a markdown rendering issue — fix table alignment, update dates, adjust backticks. User had to correct: "still not fixed."

### The Right Approach

**Step 1: Inspect raw content**

```bash
head -5 AGENTS.md | od -c
```

Output reveals:

```
0000000                       1   |   #      ...
0000100                   2   |  \n
                       3   |  \346 ...
```

Every line starts with a space-padded line number and `|` — including blank lines (`2|`).

**Step 2: Confirm with cat -A**

```bash
cat -A AGENTS.md | head -5
```

Shows: `1|# Title`, `2|$` (empty line with line number), `3|Body...`

**Step 3: Apply fix**

```bash
sed -i 's/^[[:space:]]*[0-9]\+|//' AGENTS.md
```

This removes any leading whitespace, a sequence of digits, and the pipe character.

**Step 4: Verify**

```bash
head -5 AGENTS.md
```
Output: `# Title`, blank line, `Body...` — clean.

### Root Cause

The file was likely created by saving output from a tool that prepends line numbers (like `cat -n`, `nl`, or an IDE's "copy with line numbers" feature). The line numbers became part of the file content.

### Batch Check

To find other files with the same issue:

```bash
grep -l '^[[:space:]]*[0-9]\+|#' 实体/*.md 参考资料/**/*.md 首页/*.md
```

The `#` anchor after the `|` targets files where markdown headings are affected.
