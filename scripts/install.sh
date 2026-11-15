#!/bin/sh
# install.sh - instala o desktop completo com i3 (Tango, amarelo, barra i3status) e GNU Stow
# Feito para o OpenBSD. Faz uma coisa so: monta o desktop.
# Nao mexe no sistema (doas.conf, login.conf, installurl, firmware, servicos)
# e segue o idioma do sistema (pastas XDG).
#
# Pre-requisitos (por sua conta, antes de rodar):
#   - doas configurado para o seu usuario   (doas.conf(5))
#   - mirror valido em /etc/installurl       (installurl(5))
#   - git instalado e este repositorio clonado
#
# Fica no pacote stow "scripts": depois do stow, vira ~/install.sh.
# Uso:
#   sh ~/install.sh       (ou: sh scripts/install.sh, de dentro do repositorio)
#   sh ~/install.sh -n    so mostra o que faria
#
# Nada e apagado: arquivos que atrapalham o stow vao para ~/.dotfiles-backup-DATA.

set -u

SIMULAR=0
[ "${1:-}" = "-n" ] && SIMULAR=1

# acha o repositorio mesmo quando rodado pelo link ~/install.sh
SCRIPT=$(readlink -f "$0")
REPO=$(dirname "$(dirname "$SCRIPT")")
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

STOW_PACOTES="alacritty dunst rofi tmux x11 i3 i3status scripts zathura mpv cmus vim copyq"

msg()  { printf '\033[33m==>\033[0m %s\n' "$*"; }
aviso(){ printf '\033[31m!!\033[0m %s\n' "$*"; }
rodar() {
	if [ "$SIMULAR" -eq 1 ]; then printf '    [simulado] %s\n' "$*"; else "$@"; fi
}

[ "$(uname -s)" = OpenBSD ] || { aviso "Este script e para OpenBSD."; exit 1; }
falta() { aviso "$1"; aviso "Isso e do sistema: arrume e rode de novo."; exit 1; }
doas true 2>/dev/null || falta "doas nao funciona para $(id -un). Veja doas.conf(5)."
pkg_info -Q i3 >/dev/null 2>&1 || falta "nao achei pacotes no mirror ($(cat /etc/installurl 2>/dev/null)). Veja installurl(5)."

PACOTES="stow i3 i3status i3lock alacritty rofi dunst feh scrot copyq lxappearance xdg-user-dirs"
APPS="firefox nnn zathura zathura-pdf-mupdf mpv cmus vim--no_x11"
JOGOS="supertux supertuxkart openttd"
LAZER="cmatrix tty-clock cowsay figlet sl asciiquarium"
FONTES="cascadia-code noto-emoji noto-cjk"
instalado() { pkg_info -e "${1%%--*}-*" >/dev/null 2>&1; }
instalar()  { rodar doas pkg_add -I "$1"; }

[ -d "$REPO/i3" ] || { aviso "Repositorio nao encontrado em $REPO."; exit 1; }
msg "Repositorio: $REPO"
[ "$SIMULAR" -eq 1 ] && msg "Modo simulacao: nada sera alterado."

msg "Pacotes: $PACOTES"
for p in $PACOTES; do
	if instalado "$p"; then
		printf '    %s ja instalado\n' "$p"
	else
		instalar "$p" || aviso "Nao instalou: $p (seguindo)"
	fi
done

msg "Programas: $APPS"
for p in $APPS; do
	if instalado "$p"; then
		printf '    %s ja instalado\n' "$p"
	else
		instalar "$p" || aviso "Nao instalou: $p (seguindo)"
	fi
done

msg "Fontes (opcional): $FONTES"
for p in $FONTES; do
	if instalado "$p"; then
		printf '    %s ja instalado\n' "$p"
	else
		instalar "$p" || aviso "Nao instalou: $p (seguindo; coloque os .ttf em ~/.fonts)"
	fi
done

msg "Lazer e jogos (opcional): $LAZER $JOGOS"
for p in $LAZER $JOGOS; do
	if instalado "$p"; then
		printf '    %s ja instalado\n' "$p"
	else
		instalar "$p" || aviso "Nao instalou: $p (seguindo)"
	fi
done

# pastas do usuario (Downloads, Musica...) no idioma do sistema
msg "Pastas do usuario: xdg-user-dirs-update"
rodar xdg-user-dirs-update || aviso "xdg-user-dirs-update falhou (seguindo)"

# tema GTK: escolha pelo lxappearance (o tema voce baixa por conta propria)

msg "Dotfiles (stow): $STOW_PACOTES"
for pac in $STOW_PACOTES; do
	[ -d "$REPO/$pac" ] || continue
	( cd "$REPO/$pac" && find . -type f ) | while read -r f; do
		alvo="$HOME/${f#./}"
		if [ -e "$alvo" ] && [ ! -L "$alvo" ]; then
			destino="$BACKUP/${f#./}"
			printf '    backup: %s -> %s\n' "$alvo" "$destino"
			rodar mkdir -p "$(dirname "$destino")"
			rodar mv "$alvo" "$destino"
		fi
	done
	rodar stow --no-folding -d "$REPO" -t "$HOME" "$pac" || aviso "stow falhou em $pac"
done

if [ ! -f "$HOME/.local/share/wallpapers/flores-amarelas.jpg" ]; then
	msg "Wallpaper: flores amarelas (Unsplash)"
	rodar "$REPO/scripts/.local/bin/pega-wallpaper" || aviso "Nao baixou o wallpaper (seguindo; fica a cor lisa)"
fi

msg "Pronto."
[ -d "$BACKUP" ] && msg "Arquivos antigos guardados em $BACKUP"
msg "Rode: startx  (ou entre pelo login grafico, que usa o ~/.xsession)"
