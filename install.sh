#!/usr/bin/env zsh
set -euo pipefail

# =============================================================================
# 設定
# =============================================================================
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotbackup"

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

# =============================================================================
# メイン
# =============================================================================
if [ ! -d "$BACKUP_DIR" ]; then
	echo "$BACKUP_DIR が見つかりませんでしたので新規作成します"
	mkdir "$BACKUP_DIR"
fi

typeset -A files
files=(
	"${DOTFILES_DIR}/.config/zsh/.zshrc" "${HOME}/.zshrc"
	"${DOTFILES_DIR}/.config/starship/starship.toml" "${HOME}/.config/starship.toml"
)

for src dst in "${(@kv)files}"; do
	link_file "$src" "$dst"
done
