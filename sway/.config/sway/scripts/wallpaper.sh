#!/bin/sh
# wallpaper.sh: usa ~/Imagens/wallpapers/wall.png (ou wall.jpg) como fundo, se existir
for w in "$HOME/Imagens/wallpapers/wall.png" "$HOME/Imagens/wallpapers/wall.jpg"; do
    if [ -f "$w" ]; then
        swaymsg "output * bg \"$w\" fill" >/dev/null
        exit 0
    fi
done
