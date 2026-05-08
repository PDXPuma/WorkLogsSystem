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

# Save Other Notes and Summary from existing daily log (if any)
saved_notes=""
saved_summary=""
if [ -f "$DAILYLOG_FILE" ]; then
    in_notes=0
    in_summary=0
    while IFS= read -r line; do
        if [[ "$line" == "## Other Notes" ]]; then
            in_notes=1
            in_summary=0
            continue
        elif [[ "$line" == "## Summary" ]]; then
            in_notes=0
            in_summary=1
            continue
        elif [[ "$line" =~ ^##\  ]]; then
            in_notes=0
            in_summary=0
        fi

        if [ "$in_notes" -eq 1 ] && [[ -n "$line" ]]; then
            saved_notes="$saved_notes$line"$'\n'
        elif [ "$in_summary" -eq 1 ]; then
            saved_summary="$saved_summary$line"$'\n'
        fi
    done < "$DAILYLOG_FILE"
fi

# Collect ticket entries
declare -A TICKET_ENTRIES

for worklog in "$WORKLOG_DIR"/*.md; do
    [ -f "$worklog" ] || continue

    ticket_name="$(basename "$worklog" .md)"

    # Extract only entries for this date
    entries=""
    in_section=0
    while IFS= read -r line; do
        date_pattern='^## \[([0-9]{4}-[0-9]{2}-[0-9]{2})'
        if [[ "$line" =~ $date_pattern ]]; then
            entry_date="${BASH_REMATCH[1]}"
            if [ "$entry_date" = "$GATHER_DATE" ]; then
                in_section=1
                entries="$entries$line"$'\n'
            else
                in_section=0
            fi
        elif [ "$in_section" -eq 1 ]; then
            if [[ -z "$line" ]]; then
                in_section=0
            else
                entries="$entries$line"$'\n'
            fi
        fi
    done < "$worklog"

    if [ -n "$entries" ]; then
        TICKET_ENTRIES["$ticket_name"]="$entries"
    fi
done

# If no entries found for this date
if [ ${#TICKET_ENTRIES[@]} -eq 0 ]; then
    echo "No worklog entries found for $GATHER_DATE"
    if [ ! -f "$DAILYLOG_FILE" ]; then
        {
            echo "# Daily Log: $GATHER_DATE"
            echo ""
            echo "## Worklog Entries"
            echo ""
            echo "No entries for this date."
            echo ""
            echo "## Other Notes"
            echo ""
            if [ -n "$saved_notes" ]; then
                echo -n "$saved_notes"
            fi
            echo "## Summary"
            echo ""
            if [ -n "$saved_summary" ]; then
                echo -n "$saved_summary"
            fi
        } > "$DAILYLOG_FILE"
    fi
    echo "Created empty daily log: $DAILYLOG_FILE"
    exit 0
fi

# Rebuild the daily log from scratch
echo "Gathering worklogs for $GATHER_DATE..."

{
    echo "# Daily Log: $GATHER_DATE"
    echo ""
    echo "## Worklog Entries"
    echo ""

    for ticket in $(echo "${!TICKET_ENTRIES[@]}" | tr ' ' '\n' | sort); do
        entries="${TICKET_ENTRIES[$ticket]}"
        echo "## [$GATHER_DATE] $ticket"
        echo ""
        echo -n "$entries"
        echo ""
        echo "  $ticket: entries added" >&2
    done

    echo "## Other Notes"
    echo ""
    if [ -n "$saved_notes" ]; then
        echo -n "$saved_notes"
    fi

    echo "## Summary"
    echo ""
    if [ -n "$saved_summary" ]; then
        # Strip leading blank lines from saved summary
        echo "$saved_summary" | sed '/./,$!d'
    fi
} > "$DAILYLOG_FILE"

echo "Daily log rebuilt: $DAILYLOG_FILE"
