#!/usr/bin/env bash
# add-to-daily.sh — Add free-form notes to a daily log
# Usage: add-to-daily.sh [YYYY-MM-DD] "note text"
# Example: add-to-daily.sh "Had meeting with team about sprint planning"

set -euo pipefail

DAILYLOG_DIR="$HOME/WorkLogs/daily-logs"

# Create daily-logs directory if it doesn't exist
mkdir -p "$DAILYLOG_DIR"

# Determine the date
if [ $# -ge 1 ]; then
    DAILY_DATE="$1"
    shift
    if [ $# -ge 1 ]; then
        NOTE="$*"
    else
        echo "Usage: add-to-daily.sh [YYYY-MM-DD] \"note text\""
        echo "  YYYY-MM-DD - Date of the daily log (defaults to today)"
        echo "  note text  - The note to add"
        exit 1
    fi
else
    DAILY_DATE="$(date '+%Y-%m-%d')"
    if [ $# -ge 1 ]; then
        NOTE="$*"
    else
        echo "Usage: add-to-daily.sh [YYYY-MM-DD] \"note text\""
        echo "  YYYY-MM-DD - Date of the daily log (defaults to today)"
        echo "  note text  - The note to add"
        exit 1
    fi
fi

DAILYLOG_FILE="$DAILYLOG_DIR/${DAILY_DATE}.md"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M')"

# Create daily log file if it doesn't exist
if [ ! -f "$DAILYLOG_FILE" ]; then
    echo "# Daily Log: $DAILY_DATE" > "$DAILYLOG_FILE"
    echo "" >> "$DAILYLOG_FILE"
    echo "## Worklog Entries" >> "$DAILYLOG_FILE"
    echo "" >> "$DAILYLOG_FILE"
    echo "## Other Notes" >> "$DAILYLOG_FILE"
    echo "" >> "$DAILYLOG_FILE"
    echo "## Summary" >> "$DAILYLOG_FILE"
    echo "" >> "$DAILYLOG_FILE"
fi

# Find the "Other Notes" section and append the note
# Check if "Other Notes" section exists
if ! grep -q "^## Other Notes" "$DAILYLOG_FILE" 2>/dev/null; then
    echo "" >> "$DAILYLOG_FILE"
    echo "## Other Notes" >> "$DAILYLOG_FILE"
    echo "" >> "$DAILYLOG_FILE"
fi

# Check if there's already a note in this section (to avoid duplicates)
# We add notes as bullet points under the section
echo "- [$TIMESTAMP] $NOTE" >> "$DAILYLOG_FILE"

echo "Added note to daily-logs/${DAILY_DATE}.md: [$TIMESTAMP] $NOTE"
