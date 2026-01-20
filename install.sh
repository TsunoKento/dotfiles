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

while IFS=: read -r src dst; do
	# コメント行と空行をスキップ
	[[ "$src" =~ ^# ]] && continue
	[[ -z "$src" ]] && continue

	# 変数を展開
	src="${DOTFILES_DIR}/${src}"
	dst=$(eval echo "$dst")

	# リンク先のディレクトリを確保
	ensure_dir "$(dirname "$dst")"

	link_file "$src" "$dst"
done < "${DOTFILES_DIR}/symlinks.conf"
