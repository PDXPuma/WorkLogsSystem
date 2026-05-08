---
name: repo-summarizer
description: Scan a git repo for work done on a Jira ticket and write entries to ~/WorkLogs/worklogs/<TICKET>.md. Auto-detects today's date by default, supports --from and --to for date ranges.
---

# Repo Summarizer Skill

## Purpose

Scan the current git repository for commits, file changes, and diffs related to a specific Jira ticket, then summarize the work and write timestamped entries to `worklogs/<TICKET>.md`.

## Ticket Detection

When no ticket is explicitly provided by the user, follow this priority order:

1. **Check the current branch name** — if it matches the Jira ticket pattern (`<PREFIX>-<NUMBER>`, e.g. `ABC-123`, `FEAT-42`, `AUTH-7`), use that as the ticket.
2. **If no ticket found**, invent one starting from `ZZZ-0`, incrementing (`ZZZ-1`, `ZZZ-2`, etc.) as needed. Check `~/WorkLogs/worklogs/` for existing files — skip any ZZZ number that already has a worklog file and continue incrementing until you find one that doesn't exist.

### No-Ticket Fallback

When no ticket can be identified (by any of the above methods), **get all commits for the entire day** (default: today) and write them under the invented ZZZ ticket file. The date range should cover the full day (`--since YYYY-MM-DDT00:00:00 --until YYYY-MM-DDT00:00:00`).

## How to Use

1. **Navigate to the repo** where the work was done:
   ```bash
   cd /path/to/repo
   ```

2. **Run the summarizer** (via Cursor AI):
   ```
   Summarize my work on ticket ABC-123
   ```

3. **Optionally specify a date range**:
   ```
   Summarize my work on ABC-123 from 2026-05-01 to 2026-05-05
   ```

## What This Skill Does

1. **Scan git log** for commits referencing the ticket key (search commit messages, branch names, PR titles):
   ```bash
   git log --all --grep="ABC-123" --pretty=format:"%h %ad %s" --date=short
    git log --all --oneline --since="2026-05-01T00:00:00" --until="2026-05-05T00:00:00" | grep "ABC-123"
   ```

2. **For each identified commit**, gather:
    - Commit hash, date, message
    - Files changed (added, modified, deleted)
    - Diff summary (lines added/removed)
    - Any related branches or PRs
    - **Actual content changes** — run `git show <hash>` or `git diff` to understand what was altered, not just which files changed

3. **Synthesize a concise summary** of the work done:
    - What was accomplished
    - Key files modified
    - Notable changes or fixes (describe the actual code changes, not just file names)
    - Any blockers or context

4. **Write entries to `~/WorkLogs/worklogs/<TICKET>.md`**:
    ```markdown
    ## [2026-05-08 14:30] Implemented login timeout fix in auth module
    - Modified: src/auth/middleware.py, tests/test_auth.py
    - Added timeout handling with 30s default, configurable via env var
    - Added unit tests for timeout scenarios
    ```

    For each commit entry, describe what was actually changed in the code, not just which files were touched. Use `git show <hash>` to inspect the diff and summarize the actual alterations.

## Date Detection

- **Default:** Today's date (auto-detected)
- **Override:** User can specify `--from YYYY-MM-DD --to YYYY-MM-DD` or say "from last Monday"
- The skill should interpret natural language date ranges

## Output Location

Entries are appended to: `~/WorkLogs/worklogs/<TICKET>.md`.

## When to Use

- End of day, to capture all work done on a ticket that day
- After completing a significant task, to create a worklog entry
- Before gathering daily logs, to ensure all work is captured
- After switching branches, to document what was done on each

## Important: Append Only

- **Never overwrite or delete** existing content in the worklog file
- **Never remove** manually added notes or entries
- Only **append** new entries for commits not already present
- Check for existing entries by timestamp (e.g., `## [YYYY-MM-DD HH:MM]`) to avoid duplicates
- If the file doesn't exist yet, create it
- If the file exists, read it first, then append only new entries

## Notes

- If the same ticket has work across multiple repos, run this skill in each repo
- If no commits are found for the ticket in the given date range, inform the user
