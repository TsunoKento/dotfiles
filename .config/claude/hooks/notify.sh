#!/bin/bash
# Claude Code Notification hook
# Receives JSON via stdin with keys: title, message, etc.
INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('message', 'アクションが必要です'))
" 2>/dev/null || echo "アクションが必要です")

terminal-notifier -title "Claude Code" -message "$MESSAGE" -sound "Ping"
