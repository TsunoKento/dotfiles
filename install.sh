#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# 設定
# =============================================================================
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotbackup"

# =============================================================================
# メイン
# =============================================================================
if [ ! -d "$BACKUP_DIR" ];then
	echo "$BACKUP_DIR が見つかりませんでしたので新規作成します"
	mkdir "$BACKUP_DIR"
fi

src="${DOTFILES_DIR}/.config/zsh/.zshrc"
dst="${HOME}/.zshrc"

# もしすでにシンボリックリンクがあれば削除
if [[ -L "$dst" ]];then
	rm -f "$dst"
fi

# もしすでにファイルがあったらバックアップフォルダに移動
if [[ -e "$dst" ]];then
	mv "$dst" "$HOME/.dotbackup"
fi

ln -sfn "$src" "$dst"
echo "Linked: $dst -> $src"
