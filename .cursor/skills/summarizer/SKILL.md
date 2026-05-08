---
name: summarizer
description: Summarize work logs at any granularity — daily (default), weekly, monthly, or quarterly. Auto-detects the current time period. Writes summaries to ~/WorkLogs/daily-logs/ (daily) or ~/WorkLogs/summaries/ (weekly/monthly/quarterly).
---

# Work Log Summarizer Skill

## Purpose

Summarize work done across all tracked tickets at any time granularity. By default, summarizes today's daily log. Supports weekly, monthly, and quarterly summaries.

## How to Use

1. **Daily summary** (default):
   ```
   Summarize my work today
   ```

2. **Specify a date**:
   ```
   Summarize my work for 2026-05-08
   ```

3. **Weekly summary**:
   ```
   Summarize my work this week
   Summarize my work for the week of 2026-05-04
   ```

4. **Monthly summary**:
   ```
   Summarize my work this month
   Summarize my work for April 2026
   ```

5. **Quarterly summary**:
   ```
   Summarize my work this quarter
   Summarize my work for Q2 2026
   ```

## What This Skill Does

### Daily Summary
1. Read `~/WorkLogs/daily-logs/YYYY-MM-DD.md` for the target date
2. Summarize all worklog entries grouped by ticket
3. Include any "Other Notes" from that day
4. Write the summary to the "Summary" section of that day's daily log file

### Weekly Summary
1. Identify the target week (Monday–Sunday)
2. Read all `~/WorkLogs/daily-logs/` files for that week
3. Aggregate work across all days:
   - Key accomplishments per ticket
   - Time spent patterns
   - Blocked items or blockers
   - Notable themes or context
4. Save to `~/WorkLogs/summaries/weekly-YYYY-WNN.md` (e.g., `~/WorkLogs/summaries/weekly-2026-W19.md`)

### Monthly Summary
1. Identify the target month
2. Read all `~/WorkLogs/daily-logs/` files for that month
3. Aggregate work:
   - Major deliverables completed
   - Tickets worked on and their status
   - Key metrics (tickets resolved, hours tracked)
   - Themes and patterns across the month
4. Save to `~/WorkLogs/summaries/monthly-YYYY-MM.md` (e.g., `~/WorkLogs/summaries/monthly-2026-05.md`)

### Quarterly Summary
1. Identify the target quarter (Q1=Jan–Mar, Q2=Apr–Jun, Q3=Jul–Sep, Q4=Oct–Dec)
2. Read all `~/WorkLogs/daily-logs/` and `~/WorkLogs/summaries/monthly-*/` files for that quarter
3. Aggregate work:
   - Major themes and initiatives
   - Key deliverables and outcomes
   - Notable challenges and resolutions
   - Metrics and progress toward goals
4. Save to `~/WorkLogs/summaries/quarterly-YYYY-QN.md` (e.g., `~/WorkLogs/summaries/quarterly-2026-Q2.md`)

## Summary Content Guidelines

For each time period, the summary should include:

- **Overview:** Brief paragraph describing the period's focus
- **Key Accomplishments:** Bullet list of main achievements
- **Ticket Breakdown:** Per-ticket summary of work done
- **Notes:** Any notable context from "Other Notes" sections
- **Outlook:** What's next or carry-over items (if applicable)

## Date Detection

- **Default:** Current time period (today, this week, this month, this quarter)
- **Override:** User can specify a date, week, month, or quarter
- Natural language ranges are supported (e.g., "last two weeks", "Q2")

## Output Locations

- **Daily:** Appends to `~/WorkLogs/daily-logs/YYYY-MM-DD.md` in the "Summary" section
- **Weekly:** `~/WorkLogs/summaries/weekly-YYYY-WNN.md`
- **Monthly:** `~/WorkLogs/summaries/monthly-YYYY-MM.md`
- **Quarterly:** `~/WorkLogs/summaries/quarterly-YYYY-QN.md`

## When to Use

- End of day, after gathering daily logs
- Friday afternoon, for weekly summaries
- End of month, for monthly summaries
- End of quarter, for quarterly summaries
- Before performance reviews or standup meetings
- When you need a quick refresher on what you've been working on

## Notes

- If a time period has no daily logs, the skill should inform the user
- For weekly/monthly/quarterly summaries, the skill should use monthly summaries as a first pass if available, then fill in gaps with daily logs
- The skill should be conservative with claims — only summarize what's actually logged
- If the user asks for a summary and no data exists for the period, suggest running `gather-daily.sh` for those dates
