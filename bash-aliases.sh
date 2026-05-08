# Work Logging System — Bash Aliases
# Add this to your ~/.bashrc:
#   source ~/.config/worklogs/aliases.bash

# Log work on a Jira ticket
alias log='~/.local/bin/log-work.sh'

# Gather all worklogs into today's daily log
alias daily='~/.local/bin/gather-daily.sh'

# Add a free-form note to a daily log
alias note='~/.local/bin/add-to-daily.sh'

# Open today's daily log in nvim
alias today='nvim ~/WorkLogs/daily-logs/$(date +%Y-%m-%d).md'

# Browse and open daily logs with television
dl() {
  local file
  file=$(ls ~/WorkLogs/daily-logs/ | tv -p "bat --color=always ~/WorkLogs/daily-logs/{}" | sed "s|^|$HOME/WorkLogs/daily-logs/|")
  [ -n "$file" ] && nvim "$file"
}

# Browse and open worklogs with television
wl() {
  local file
  file=$(ls ~/WorkLogs/worklogs/ | tv -p "bat --color=always ~/WorkLogs/worklogs/{}" | sed "s|^|$HOME/WorkLogs/worklogs/|")
  [ -n "$file" ] && nvim "$file"
}
