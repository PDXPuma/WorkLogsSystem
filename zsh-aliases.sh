# Work Logging System — zsh Aliases
# Source this file in your ~/.zshrc:
#   source ~/.config/worklogs/aliases.zsh

# Log work on a Jira ticket
alias log='~/.local/bin/log-work.sh'

# Gather all worklogs into today's daily log
alias daily='~/.local/bin/gather-daily.sh'

# Add a free-form note to a daily log
alias note='~/.local/bin/add-to-daily.sh'
