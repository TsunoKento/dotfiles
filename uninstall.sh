#!/usr/bin/env zsh
set -euo pipefail

# =============================================================================
# メイン
# =============================================================================
targets=(
	"${HOME}/.zshrc"
	"${HOME}/.config/starship.toml"
)

for target in "${targets[@]}"; do
	if [[ -L "$target" ]]; then
		rm -f "$target"
		echo "Deleted symlink: $target"
	fi
done
