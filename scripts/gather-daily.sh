#!/usr/bin/env bash
# gather-daily.sh — Gather all worklogs for a given date into a daily log
# Usage: gather-daily.sh [YYYY-MM-DD]
# Example: gather-daily.sh 2026-05-08

set -euo pipefail

WORKLOG_DIR="$HOME/WorkLogs/worklogs"
DAILYLOG_DIR="$HOME/WorkLogs/daily-logs"

# Create daily-logs directory if it doesn't exist
mkdir -p "$DAILYLOG_DIR"

# Determine the date to gather
if [ $# -ge 1 ]; then
    GATHER_DATE="$1"
else
    GATHER_DATE="$(date '+%Y-%m-%d')"
fi

DAILYLOG_FILE="$DAILYLOG_DIR/${GATHER_DATE}.md"

# Check if any worklog files exist
if [ ! -d "$WORKLOG_DIR" ] || [ -z "$(ls -A "$WORKLOG_DIR" 2>/dev/null)" ]; then
    echo "No worklog files found in worklogs/ for $GATHER_DATE"
    exit 0
fi

# Find all tickets that have entries for this date
echo "Gathering worklogs for $GATHER_DATE..."

# Collect ticket entries
declare -A TICKET_ENTRIES

for worklog in "$WORKLOG_DIR"/*.md; do
    [ -f "$worklog" ] || continue
    
    ticket_name="$(basename "$worklog" .md)"
    
    # Extract only entries for this date
    entries=""
    in_section=0
    while IFS= read -r line; do
        # Check if this is a section header (## [...])
        if [[ "$line" =~ ^##\ \[([0-9]{4}-[0-9]{2}-[0-9]{2})\ ]]; then
            entry_date="${BASH_REMATCH[1]}"
            if [ "$entry_date" = "$GATHER_DATE" ]; then
                in_section=1
                entries="$entries$line"$'\n'
            else
                in_section=0
            fi
        elif [ "$in_section" -eq 1 ]; then
            # Continue collecting until next section or blank line
            if [[ -z "$line" ]]; then
                # Blank line ends this entry block
                in_section=0
            else
                entries="$entries$line"$'\n'
            fi
        fi
    done < "$worklog"
    
    # Only include tickets that have entries for this date
    if [ -n "$entries" ]; then
        TICKET_ENTRIES["$ticket_name"]="$entries"
    fi
done

# If no entries found for this date, exit quietly
if [ ${#TICKET_ENTRIES[@]} -eq 0 ]; then
    echo "No worklog entries found for $GATHER_DATE"
    # Create empty daily log with sections
    if [ ! -f "$DAILYLOG_FILE" ]; then
        echo "# Daily Log: $GATHER_DATE" > "$DAILYLOG_FILE"
        echo "" >> "$DAILYLOG_FILE"
        echo "## Worklog Entries" >> "$DAILYLOG_FILE"
        echo "" >> "$DAILYLOG_FILE"
        echo "No entries for this date." >> "$DAILYLOG_FILE"
        echo "" >> "$DAILYLOG_FILE"
        echo "## Other Notes" >> "$DAILYLOG_FILE"
        echo "" >> "$DAILYLOG_FILE"
        echo "## Summary" >> "$DAILYLOG_FILE"
        echo "" >> "$DAILYLOG_FILE"
    fi
    echo "Created empty daily log: $DAILYLOG_FILE"
    exit 0
fi

# Create daily log file if it doesn't exist
if [ ! -f "$DAILYLOG_FILE" ]; then
    echo "# Daily Log: $GATHER_DATE" > "$DAILYLOG_FILE"
    echo "" >> "$DAILYLOG_FILE"
    echo "## Worklog Entries" >> "$DAILYLOG_FILE"
    echo "" >> "$DAILYLOG_FILE"
    echo "## Other Notes" >> "$DAILYLOG_FILE"
    echo "" >> "$DAILYLOG_FILE"
    echo "## Summary" >> "$DAILYLOG_FILE"
    echo "" >> "$DAILYLOG_FILE"
fi

# Check if worklog entries section already exists with content
if grep -q "No entries for this date" "$DAILYLOG_FILE" 2>/dev/null; then
    # Replace the placeholder text
    sed -i '/No entries for this date./d' "$DAILYLOG_FILE"
fi

# Append entries for each ticket that has work for this date
# Check if we need to add a blank line before the first ticket section
if ! grep -q "^## \[" "$DAILYLOG_FILE" 2>/dev/null; then
    : # No ticket sections exist yet, will add them
fi

for ticket in $(echo "${!TICKET_ENTRIES[@]}" | tr ' ' '\n' | sort); do
    entries="${TICKET_ENTRIES[$ticket]}"
    
    # Check if this ticket's section already exists in the daily log for this date
    if grep -q "^## \[$GATHER_DATE\].*$ticket" "$DAILYLOG_FILE" 2>/dev/null; then
        echo "  $ticket: already in daily log, skipping"
        continue
    fi
    
    # Append the ticket section
    echo "## [$GATHER_DATE] $ticket" >> "$DAILYLOG_FILE"
    echo "" >> "$DAILYLOG_FILE"
    echo -n "$entries" >> "$DAILYLOG_FILE"
    echo "" >> "$DAILYLOG_FILE"
    echo "  $ticket: entries added"
done

echo "Daily log updated: $DAILYLOG_FILE"
