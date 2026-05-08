---
name: querier
description: Query work logs and daily logs with natural language questions. Answers questions about what you worked on, time spent, ticket status, and more. Outputs to terminal by default, supports --output flag to save to file.
---

# Work Log Querier Skill

## Purpose

Answer natural language questions about your work logs. Reads from `worklogs/` and `daily-logs/` to synthesize answers about your work history.

## How to Use

1. **Ask a question** (via Cursor AI):
   ```
   What did I work on last week?
   How much time did I spend on ABC-123 this month?
   Show me all tickets I worked on in April
   What were my main accomplishments this quarter?
   Did I make any commits related to DEF-456?
   ```

2. **Save results to a file**:
   ```
   Query: What did I work on last week?
   Save to: weekly-summary.md
   ```

## What This Skill Does

1. **Parse the user's question** to determine:
   - What information is being requested
   - The relevant time period (auto-detected if not specified)
   - Any specific tickets, repos, or keywords to filter by

2. **Read the appropriate log files**:
   - `worklogs/<TICKET>.md` — for ticket-specific queries
   - `daily-logs/YYYY-MM-DD.md` — for time-period queries
   - `summaries/` — for pre-computed summaries (weekly/monthly/quarterly)

3. **Filter and synthesize** the relevant data:
   - Date range filtering
   - Ticket filtering
   - Keyword matching
   - Aggregation of time spent, commits, etc.

4. **Provide a clear, structured answer** based on the logged data

## Supported Question Types

### Work History
- "What did I work on [time period]?"
- "Show me my work on [ticket] [time period]?"
- "What did I do on [date]?"

### Time Tracking
- "How much time did I spend on [ticket]?"
- "When did I last work on [ticket]?"
- "How many days did I work on [ticket] this month?"

### Ticket Status
- "What's the status of [ticket]?"
- "What work have I done on [ticket]?"
- "Has [ticket] been updated this week?"

### Commit History
- "What commits did I make related to [ticket]?"
- "Show me my last [N] commits"
- "What files did I change on [date]?"

### Themes & Patterns
- "What were my main focus areas this month?"
- "Which tickets did I work on most this quarter?"
- "What's been my biggest project this month?"

## Date Detection

- **Default:** Auto-detect from the question's wording:
  - "today" / "now" → current date
  - "this week" → current week (Mon–Sun)
  - "last week" → previous week
  - "this month" → current month
  - "last month" → previous month
  - "this quarter" → current quarter
  - "last quarter" → previous quarter
  - "yesterday" → previous day
  - Specific dates → that date
- **Override:** User can specify explicit dates

## Output

- **Default:** Display answer in terminal/output
- **Optional:** Save to file with `--output <filename>` or "save to <file>"

## Example Queries and Responses

**Query:** "What did I work on last week?"
**Response:** 
```
## Work Summary: May 1–5, 2026

### Key Accomplishments
- **ABC-123** (Login timeout fix):
  - Implemented timeout middleware in auth module
  - Added configurable timeout via environment variable
  - Completed unit tests for timeout scenarios
  - Deployed to staging for QA

- **DEF-456** (Dashboard redesign):
  - Updated component structure for new layout
  - Fixed data binding issues in chart components
  - Code reviewed teammate's PR #234

### Other Notes
- Had sprint planning meeting on May 2
- Demo completed for DEF-456 on May 5
```

**Query:** "How much time did I spend on ABC-123 this month?"
**Response:**
```
## Time Spent on ABC-123 — May 2026

| Date       | Duration | Description                              |
|------------|----------|------------------------------------------|
| May 1      | ~2h      | Initial investigation of timeout issue   |
| May 3      | ~3h      | Implemented timeout middleware           |
| May 4      | ~1.5h    | Added unit tests                         |
| May 5      | ~1h      | Staging deployment and QA support        |

**Total: ~7.5 hours across 4 days**
```

## Notes

- If no data exists for the queried period, inform the user and suggest what they might want to do
- For time estimates, use the number of log entries as a proxy (each entry ≈ 30–60 min of work)
- When the question is ambiguous, ask for clarification before querying
- Always cite the source files used in the answer
- If the user asks about a ticket that has no worklog entries, suggest checking if the work was logged
