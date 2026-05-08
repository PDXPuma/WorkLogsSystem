# Work Logging System

Automated work logging through shell scripts and Cursor AI skills. Track Jira ticket work, aggregate daily logs, and get summaries at any granularity.

## Directory Structure

```
WorkLogsSystem/
├── worklogs/                    # Per-ticket log files (ABC-123.md, DEF-456.md, etc.) — now at ~/WorkLogs/worklogs/
├── daily-logs/                  # Aggregated daily logs (2026-05-08.md, etc.) — now at ~/WorkLogs/daily-logs/
├── summaries/                   # Weekly/monthly/quarterly summaries — now at ~/WorkLogs/summaries/
│   ├── weekly-2026-W19.md
│   ├── monthly-2026-05.md
│   └── quarterly-2026-Q2.md
├── scripts/                     # Shell scripts (also installed to ~/.local/bin/)
│   ├── log-work.sh
│   ├── gather-daily.sh
│   └── add-to-daily.sh
├── .cursor/skills/              # Cursor AI skills
│   ├── repo-summarizer/         # Scan git history → write to worklog
│   ├── summarizer/              # Summarize logs (daily/weekly/monthly/quarterly)
│   └── querier/                 # Query logs with natural language
├── .opencode/skills/            # OpenCode AI skills (same as above)
├── install.sh                   # Installer to ~/.local/bin
├── zsh-aliases.sh               # zsh aliases (sourced via ~/.config/worklogs/aliases.zsh)
├── bash-aliases.sh              # bash aliases (sourced via ~/.config/worklogs/aliases.bash)
└── README.md                    # This file
```

## Installation

Run the installer:

```bash
./install.sh
```

This:
- Copies scripts to `~/.local/bin/`
- Creates `~/.config/worklogs/aliases.zsh` with zsh aliases (`log-work`, `gather-daily`, `add-to-daily`, `today`, `dl`, `wl`)
- Creates `~/.config/worklogs/aliases.bash` with bash aliases (`log`, `daily`, `note`, `today`, `dl`, `wl`)
- Adds the source line to `~/.zshrc` and `~/.bashrc`
- Creates `~/WorkLogs/worklogs/`, `~/WorkLogs/daily-logs/`, and `~/WorkLogs/summaries/` directories
- Installs OpenCode skills to `~/.config/opencode/skills/`

Then reload your shell:

```bash
source ~/.zshrc  # or source ~/.bashrc
```

## Daily Workflow

### During the Day — Log Work

**Option 1: Manual entry**
```bash
log-work ABC-123 "Implemented login timeout fix"
```

**Option 2: Auto-scan git history** (via Cursor AI)
- Open Cursor AI
- Navigate to the repo where you worked
- Ask: "Summarize my work on ABC-123"
- The repo-summarizer skill scans git log, diffs, and file changes
- Writes timestamped entries to `~/WorkLogs/worklogs/ABC-123.md`

### End of Day — Gather Logs

```bash
gather-daily              # Gather today's worklogs into ~/WorkLogs/daily-logs/2026-05-08.md
gather-daily 2026-05-07   # Gather a specific date
```

This:
- Reads all files in `~/WorkLogs/worklogs/`
- Pulls only entries for the given date
- Groups them by ticket in `~/WorkLogs/daily-logs/YYYY-MM-DD.md`
- Only creates sections for tickets that actually have entries that day

### Add Other Notes

```bash
add-to-daily "Had meeting with team about sprint planning"
add-to-daily 2026-05-07 "Demo completed for DEF-456"
```

Notes go under the "Other Notes" section of the daily log.

### Browse Logs

**Open today's daily log:**
```bash
today
```

**Browse daily logs with television:**
```bash
dl
```

**Browse worklogs with television:**
```bash
wl
```

All three open files directly in nvim. `dl` and `wl` use tv (television) to let you pick from existing files.

### Summarize

**Daily** (default):
```
Ask Cursor AI: "Summarize my work today"
```
The summarizer skill reads today's daily log and writes a summary to the "Summary" section.

**Weekly/Monthly/Quarterly:**
```
Ask Cursor AI: "Summarize my work this week"
Ask Cursor AI: "Summarize my work for April"
Ask Cursor AI: "Summarize my work this quarter"
```
Summaries are saved to `~/WorkLogs/summaries/weekly-YYYY-WNN.md`, `~/WorkLogs/summaries/monthly-YYYY-MM.md`, or `~/WorkLogs/summaries/quarterly-YYYY-QN.md`.

### Query Your Logs

```
Ask Cursor AI: "What did I work on last week?"
Ask Cursor AI: "How much time did I spend on ABC-123 this month?"
Ask Cursor AI: "Show me all tickets I worked on in April"
Ask Cursor AI: "What commits did I make related to DEF-456?"
```

Results display in terminal by default. To save to a file:
```
Ask Cursor AI: "What did I work on last week? Save to weekly-summary.md"
```

## Script Reference

### log-work.sh
```bash
log-work.sh <TICKET> <description>
log-work ABC-123 "Fixed login timeout issue"
```
Appends a timestamped entry to `~/WorkLogs/worklogs/<TICKET>.md`.

### gather-daily.sh
```bash
gather-daily.sh [YYYY-MM-DD]
gather-daily                    # defaults to today
gather-daily 2026-05-07         # specific date
```
Gathers all worklog entries for the given date into `~/WorkLogs/daily-logs/YYYY-MM-DD.md`. Appends to existing files (no duplicates).

### add-to-daily.sh
```bash
add-to-daily.sh [YYYY-MM-DD] "note text"
add-to-daily "Had a productive day"
add-to-daily 2026-05-07 "Demo completed"
```
Appends a timestamped note to the "Other Notes" section of the daily log.

## Cursor AI Skills Reference

### repo-summarizer
Scans git history for work on a specific ticket and writes entries to the worklog.

- **Auto-detects** today's date
- **Override:** "from last Monday" or "from 2026-05-01 to 2026-05-05"
- **Run from:** Inside the repo directory
- **Output:** Entries in `~/WorkLogs/worklogs/<TICKET>.md`

### summarizer
Summarizes work logs at any granularity.

- **Default:** Daily (today's log)
- **Modes:** daily, weekly, monthly, quarterly
- **Auto-detects** the current time period
- **Override:** "for April", "this quarter", "week of 2026-05-04"
- **Output:** Appends to daily log (daily) or `~/WorkLogs/summaries/` (weekly/monthly/quarterly)

### querier
Answer natural language questions about your work logs.

- **Examples:**
  - "What did I work on last week?"
  - "How much time on ABC-123 this month?"
  - "Show me all tickets worked on in April"
  - "What were my main accomplishments this quarter?"
- **Save to file:** "Save to weekly-summary.md"
- **Auto-detects** date ranges from the question

## File Formats

### worklogs/<TICKET>.md
```markdown
# Worklog: ABC-123

## [2026-05-08 09:15] Initial investigation of timeout issue
## [2026-05-08 14:30] Implemented timeout middleware in auth module
## [2026-05-08 16:00] Added unit tests for timeout scenarios
```

### daily-logs/YYYY-MM-DD.md
```markdown
# Daily Log: 2026-05-08

## Worklog Entries

## [2026-05-08] ABC-123

## [2026-05-08 09:15] Initial investigation of timeout issue
## [2026-05-08 14:30] Implemented timeout middleware in auth module
## [2026-05-08 16:00] Added unit tests for timeout scenarios

## [2026-05-08] DEF-456

## [2026-05-08 10:00] Updated dashboard component structure

## Other Notes

- [2026-05-08 17:00] Had sprint planning meeting

## Summary

[Summary written by the summarizer skill]
```

### summaries/weekly-YYYY-WNN.md
```markdown
# Weekly Summary: Week 19, 2026 (May 4–10)

## Overview
[Summary paragraph]

## Key Accomplishments
- ABC-123: Login timeout fix completed and deployed
- DEF-456: Dashboard redesign in progress

## Ticket Breakdown
### ABC-123
- Summary of daily work across the week

### DEF-456
- Summary of daily work across the week

## Notes
[Notable context from Other Notes sections]

## Outlook
[Carry-over items and next steps]
```

## Tips

- **Run `gather-daily.sh` at least once at end of day** to ensure all work is captured
- **Run `log-work.sh` or use the repo-summarizer skill** when switching between tasks
- **Use the querier skill** before standup meetings to quickly recall what you worked on
- **Generate weekly summaries** on Friday afternoons for your standup notes
- **Generate monthly summaries** at month-end for your own records or performance reviews
- **The system is additive** — daily logs only grow, never shrink, so past data is always available
