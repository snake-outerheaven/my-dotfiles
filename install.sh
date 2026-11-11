#!/bin/sh
# install.sh - instala o ambiente i3 (Everforest) no OpenBSD com GNU Stow
#
# Uso (na raiz do repositorio):
#   sh install.sh       instala pacotes e aplica os dotfiles no $HOME
#   sh install.sh -n    so mostra o que faria
#
# Nada e apagado: arquivos que atrapalham o stow vao para ~/.dotfiles-backup-DATA.

set -u

SIMULAR=0
[ "${1:-}" = "-n" ] && SIMULAR=1

REPO=$(cd "$(dirname "$0")" && pwd)
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

PACOTES="stow i3 i3status i3lock alacritty rofi dunst picom feh scrot"
STOW_PACOTES="i3 i3status alacritty dunst picom rofi tmux x11"

msg()  { printf '\033[32m==>\033[0m %s\n' "$*"; }
aviso(){ printf '\033[31m!!\033[0m %s\n' "$*"; }
rodar() {
	if [ "$SIMULAR" -eq 1 ]; then printf '    [simulado] %s\n' "$*"; else "$@"; fi
}

[ "$(uname -s)" = "OpenBSD" ] || { aviso "Este script e para OpenBSD."; exit 1; }
command -v doas >/dev/null || { aviso "doas nao encontrado. Configure o /etc/doas.conf."; exit 1; }
[ "$SIMULAR" -eq 1 ] && msg "Modo simulacao: nada sera alterado."

msg "Pacotes: $PACOTES"
for p in $PACOTES; do
	if pkg_info -e "$p-*" >/dev/null 2>&1; then
		printf '    %s ja instalado\n' "$p"
	else
		rodar doas pkg_add -I "$p" || aviso "Nao instalou: $p (seguindo)"
	fi
done

rodar mkdir -p "$HOME/Imagens/Printscreens"

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

msg "Pronto."
[ -d "$BACKUP" ] && msg "Arquivos antigos guardados em $BACKUP"
msg "Rode: startx  (ou entre pelo xenodm, que usa o ~/.xsession)"
