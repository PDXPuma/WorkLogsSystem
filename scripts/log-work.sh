#!/usr/bin/env bash
# log-work.sh — Log work done on a Jira ticket
# Usage: log-work.sh <TICKET> <description>
# Example: log-work.sh ABC-123 "Fixed login timeout issue"

set -euo pipefail

WORKLOG_DIR="$HOME/WorkLogs/worklogs"

# Create worklogs directory if it doesn't exist
mkdir -p "$WORKLOG_DIR"

if [ $# -lt 2 ]; then
    echo "Usage: log-work.sh <TICKET> <description>"
    echo "  TICKET     - Jira ticket key (e.g., ABC-123)"
    echo "  description - Brief description of the work done"
    exit 1
fi

TICKET="$1"
shift
DESCRIPTION="$*"

WORKLOG_FILE="$WORKLOG_DIR/${TICKET}.md"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M')"

# Create worklog file with header if it doesn't exist
if [ ! -f "$WORKLOG_FILE" ]; then
    echo "# Worklog: $TICKET" > "$WORKLOG_FILE"
    echo "" >> "$WORKLOG_FILE"
fi

# Append entry
echo "## [$TIMESTAMP] $DESCRIPTION" >> "$WORKLOG_FILE"

echo "Logged to worklogs/${TICKET}.md: [$TIMESTAMP] $DESCRIPTION"
