#!/usr/bin/env bash
# install.sh — Install work logging system to ~/.local/bin
# Usage: ./install.sh
#
# Copies scripts to ~/.local/bin/ and sets up zsh aliases.
# Safe to run multiple times (idempotent).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.local/bin"
ALIASES_DIR="$HOME/.config/worklogs"
ALIASES_FILE="$ALIASES_DIR/aliases.zsh"
ALIASES_BASH_FILE="$ALIASES_DIR/aliases.bash"
ZSHRC="$HOME/.zshrc"
BASHRC="$HOME/.bashrc"

echo "Installing Work Logging System..."

# 1. Create install directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$ALIASES_DIR"

# 2. Copy scripts to ~/.local/bin/
echo "  Copying scripts to $INSTALL_DIR..."
for script in "$SCRIPT_DIR"/scripts/*.sh; do
    script_name="$(basename "$script")"
    cp "$script" "$INSTALL_DIR/$script_name"
    chmod +x "$INSTALL_DIR/$script_name"
    echo "    $script_name → $INSTALL_DIR/$script_name"
done

# 3. Create zsh aliases file
echo "  Creating aliases at $ALIASES_FILE..."
cat > "$ALIASES_FILE" << 'EOF'
# Work Logging System — zsh Aliases
# Source this file in your ~/.zshrc:
#   source ~/.config/worklogs/aliases.zsh

# Log work on a Jira ticket
alias log-work='~/.local/bin/log-work.sh'

# Gather all worklogs into today's daily log
alias gather-daily='~/.local/bin/gather-daily.sh'

# Add a free-form note to a daily log
alias add-to-daily='~/.local/bin/add-to-daily.sh'

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
EOF

# 3b. Create bash aliases file
if [ -f "$SCRIPT_DIR/bash-aliases.sh" ]; then
    cp "$SCRIPT_DIR/bash-aliases.sh" "$ALIASES_BASH_FILE"
    echo "  Created bash aliases at $ALIASES_BASH_FILE"
fi

# 4. Add source line to ~/.zshrc if not already present
if ! grep -q "worklogs/aliases.zsh" "$ZSHRC" 2>/dev/null; then
    echo "" >> "$ZSHRC"
    echo "# Work Logging System" >> "$ZSHRC"
    echo "source ~/.config/worklogs/aliases.zsh" >> "$ZSHRC"
    echo "  Added source line to $ZSHRC"
else
    echo "  Aliases already sourced in $ZSHRC"
fi

# 4b. Add source line to ~/.bashrc if not already present
if [ -f "$BASHRC" ]; then
    if ! grep -q "worklogs/aliases.bash" "$BASHRC" 2>/dev/null; then
        echo "" >> "$BASHRC"
        echo "# Work Logging System" >> "$BASHRC"
        echo "source ~/.config/worklogs/aliases.bash" >> "$BASHRC"
        echo "  Added source line to $BASHRC"
    else
        echo "  Aliases already sourced in $BASHRC"
    fi
fi

# 5. Create worklogs, daily-logs, and summaries directories in ~/WorkLogs
mkdir -p "$HOME/WorkLogs/worklogs"
mkdir -p "$HOME/WorkLogs/daily-logs"
mkdir -p "$HOME/WorkLogs/summaries"

# 6. Install opencode skills to ~/.config/opencode/skills/
OPENCOD_SKILLS_DIR="$HOME/.config/opencode/skills"
if [ -d "$SCRIPT_DIR/.opencode/skills" ]; then
    echo "  Installing opencode skills to $OPENCOD_SKILLS_DIR..."
    mkdir -p "$OPENCOD_SKILLS_DIR"
    for skill_dir in "$SCRIPT_DIR/.opencode/skills"/*/; do
        if [ -d "$skill_dir" ]; then
            skill_name="$(basename "$skill_dir")"
            mkdir -p "$OPENCOD_SKILLS_DIR/$skill_name"
            for skill_file in "$skill_dir"*.md; do
                if [ -f "$skill_file" ]; then
                    cp "$skill_file" "$OPENCOD_SKILLS_DIR/$skill_name/"
                    echo "    $skill_name/$(basename "$skill_file") → $OPENCOD_SKILLS_DIR/$skill_name/"
                fi
            done
        fi
    done
fi

echo ""
echo "Installation complete!"
echo ""
echo "To start using the aliases, run:"
echo "  source $ZSHRC"
echo ""
echo "Or restart your terminal."
echo ""
echo "Quick start:"
echo "  log-work ABC-123 'Fixed login timeout'"
echo "  gather-daily"
echo "  add-to-daily 'Had meeting with team'"
echo "  today          # Open today's daily log"
echo "  dl             # Browse daily logs with television"
echo "  wl             # Browse worklogs with television"
