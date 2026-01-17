#!/usr/bin/env zsh
set -euo pipefail

# =============================================================================
# 設定
# =============================================================================
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotbackup"
CONFIG_DIR="$HOME/.config"

# =============================================================================
# 関数
# =============================================================================
link_file() {
	local src="$1"
	local dst="$2"

	# もしすでにシンボリックリンクがあれば削除
	if [[ -L "$dst" ]]; then
		rm -f "$dst"
	fi

	# もしすでにファイルがあったらバックアップフォルダに移動
	if [[ -e "$dst" ]]; then
		mv "$dst" "$BACKUP_DIR"
	fi

	ln -sfn "$src" "$dst"
	echo "Linked: $dst -> $src"
}

ensure_dir() {
	local dir="$1"
	if [ ! -d "$dir" ]; then
		echo "$dir が見つかりませんでしたので新規作成します"
		mkdir "$dir"
	fi
}

# =============================================================================
# メイン
# =============================================================================
ensure_dir "$BACKUP_DIR"
ensure_dir "$CONFIG_DIR"
ensure_dir "$HOME/.claude"

typeset -A files
files=(
	"${DOTFILES_DIR}/.config/zsh/.zshrc" "${HOME}/.zshrc"
	"${DOTFILES_DIR}/.config/starship/starship.toml" "${HOME}/.config/starship.toml"
	"${DOTFILES_DIR}/.config/claude/settings.json" "${HOME}/.claude/settings.json"
)

for src dst in "${(@kv)files}"; do
	link_file "$src" "$dst"
done
