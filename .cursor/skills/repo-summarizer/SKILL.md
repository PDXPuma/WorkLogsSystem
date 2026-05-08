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

When no ticket can be identified (by any of the above methods), **get all commits for the entire day** (default: today) and write them under the invented ZZZ ticket file. The date range should cover the full day (`--since YYYY-MM-DD --until YYYY-MM-DD`).

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
   git log --all --oneline --since="2026-05-01" --until="2026-05-05" | grep "ABC-123"
   ```

2. **For each identified commit**, gather:
   - Commit hash, date, message
   - Files changed (added, modified, deleted)
   - Diff summary (lines added/removed)
   - Any related branches or PRs

3. **Synthesize a concise summary** of the work done:
   - What was accomplished
   - Key files modified
   - Notable changes or fixes
   - Any blockers or context

4. **Write entries to `~/WorkLogs/worklogs/<TICKET>.md`**:
   ```markdown
   ## [2026-05-08 14:30] Implemented login timeout fix in auth module
   - Modified: src/auth/middleware.py, tests/test_auth.py
   - Added timeout handling with 30s default, configurable via env var
   - Added unit tests for timeout scenarios
   ```

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

## Notes

- If the same ticket has work across multiple repos, run this skill in each repo
- The skill should be idempotent — running it twice shouldn't create duplicate entries
- If no commits are found for the ticket in the given date range, inform the user
