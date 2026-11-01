#!/bin/sh
# wallpaper.sh: aplica o wallpaper ao iniciar/recarregar o Sway
#   1) a escolha salva pelo wall.sh (~/.config/sway/wallpaper.atual)
#   2) senao, ~/Imagens/wallpapers/wall.png ou wall.jpg
ATUAL="$HOME/.config/sway/wallpaper.atual"
if [ -f "$ATUAL" ]; then
    img=$(cut -f1 "$ATUAL"); modo=$(cut -f2 "$ATUAL")
    if [ -f "$img" ]; then
        swaymsg "output * bg \"$img\" ${modo:-fill} #282828" >/dev/null
        exit 0
    fi
fi
for w in "$HOME/Imagens/wallpapers/wall.png" "$HOME/Imagens/wallpapers/wall.jpg"; do
    if [ -f "$w" ]; then
        swaymsg "output * bg \"$w\" fill" >/dev/null
        exit 0
    fi
done
