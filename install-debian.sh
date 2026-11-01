#!/bin/sh
# install-debian.sh: instala o Sway (Debian 13) e liga os dotfiles com o GNU stow
# Uso: sh install-debian.sh     (rode como usuario normal, na raiz do repositorio)
set -eu

PACOTES="sway swaybg swayidle swaylock xwayland
grim slurp wl-clipboard cliphist libnotify-bin
fuzzel alacritty dunst tmux
xdg-desktop-portal-wlr xdg-desktop-portal-gtk
network-manager-gnome gnome-keyring dex
pulseaudio-utils brightnessctl playerctl
fonts-noto-core fonts-noto-color-emoji fonts-cascadia-code
libglib2.0-bin dconf-gsettings-backend wget stow"

echo "== pacotes"
sudo apt update
# shellcheck disable=SC2086
sudo apt install -y $PACOTES

echo "== dotfiles (stow)"
cd "$(dirname "$0")"
mkdir -p "$HOME/.config"
for p in sway swaylock fuzzel alacritty dunst tmux autostart; do
    stow --no-folding -v -t "$HOME" "$p"
done

mkdir -p "$HOME/Imagens/Printscreens"

echo "== wallpaper"
WALL="$HOME/Imagens/wallpapers/wall.jpg"
BASE="https://raw.githubusercontent.com/vctrblck/gruvbox-wallpapers/main"
mkdir -p "$(dirname "$WALL")"
if [ -f "$WALL" ]; then
    echo "ja existe: $WALL (mantido)"
else
    for img in forest.jpg cabin.png buildings.png; do
        if wget -q -O "$WALL.tmp" "$BASE/$img"; then
            mv "$WALL.tmp" "$WALL"; echo "baixado: $img -> $WALL"; break
        fi
        rm -f "$WALL.tmp"; echo "nao achei $img, tentando o proximo"
    done
fi
# aplica na hora se o Sway ja estiver aberto
if [ -f "$WALL" ] && command -v swaymsg >/dev/null && swaymsg -t get_version >/dev/null 2>&1; then
    swaymsg reload >/dev/null && echo "wallpaper aplicado (swaymsg reload)"
fi

echo
echo "pronto. Saia da sessao e entre em 'Sway' na tela de login (ou rode 'sway' num TTY)."
echo "validar a config sem entrar: sway --validate"
