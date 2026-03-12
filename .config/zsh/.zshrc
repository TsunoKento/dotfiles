export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"
export PATH="$PATH:$(go env GOPATH)/bin"

alias ll='ls -lh'
alias lr='ll -R'
alias la='ll -A'

eval "$(starship init zsh)"
