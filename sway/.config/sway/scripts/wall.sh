#!/bin/sh
# wall.sh: troca o wallpaper do Sway e guarda a escolha
#   wall.sh /caminho/imagem.jpg          usa a imagem (preenchendo a tela)
#   wall.sh /caminho/imagem.jpg fit      mostra o quadro inteiro, com faixas escuras
#   wall.sh                              lista as imagens de ~/Imagens/wallpapers
set -eu
ATUAL="$HOME/.config/sway/wallpaper.atual"

if [ $# -eq 0 ]; then
    echo "atual: $(cat "$ATUAL" 2>/dev/null || echo 'padrao (wall.png/wall.jpg)')"
    find "$HOME/Imagens/wallpapers" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort
    exit 0
fi

img=$(realpath "$1")
modo="${2:-fill}"
case "$modo" in fill|fit|center|tile|stretch) ;; *) echo "modo invalido: $modo (fill, fit, center, tile, stretch)" >&2; exit 1 ;; esac
[ -f "$img" ] || { echo "nao achei: $img" >&2; exit 1; }

printf '%s\t%s\n' "$img" "$modo" > "$ATUAL"
swaymsg "output * bg \"$img\" $modo #282828" >/dev/null && echo "wallpaper: $img ($modo)"
