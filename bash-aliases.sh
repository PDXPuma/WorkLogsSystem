# Work Logging System — Bash Aliases
# Add this to your ~/.bashrc:
#   source ~/.config/worklogs/aliases.bash

# Log work on a Jira ticket
alias log='~/.local/bin/log-work.sh'

# Gather all worklogs into today's daily log
alias daily='~/.local/bin/gather-daily.sh'

# Add a free-form note to a daily log
alias note='~/.local/bin/add-to-daily.sh'
