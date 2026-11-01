#!/bin/sh
# install-debian.sh: instala o Sway (Debian 13) e liga os dotfiles com o GNU stow
# Uso: sh install-debian.sh     (rode como usuario normal, na raiz do repositorio)
set -eu

PACOTES="sway swaybg swayidle swaylock xwayland
grim slurp wl-clipboard libnotify-bin
fuzzel alacritty dunst tmux
xdg-desktop-portal-wlr xdg-desktop-portal-gtk
network-manager-gnome gnome-keyring dex
bumblebee-status pulseaudio-utils brightnessctl playerctl
fonts-noto-core fonts-noto-color-emoji fonts-cascadia-code
libglib2.0-bin stow"

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

echo
echo "pronto. Saia da sessao e entre em 'Sway' na tela de login (ou rode 'sway' num TTY)."
echo "validar a config sem entrar: sway --validate"
