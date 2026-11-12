#!/bin/sh
# install.sh - instala o desktop completo com cwm (Gruvbox, amarelo) e GNU Stow
# Feito para o OpenBSD.
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

STOW_PACOTES="alacritty dunst rofi tmux x11 gtk cwm scripts zathura mpv vim"

msg()  { printf '\033[33m==>\033[0m %s\n' "$*"; }
aviso(){ printf '\033[31m!!\033[0m %s\n' "$*"; }
rodar() {
	if [ "$SIMULAR" -eq 1 ]; then printf '    [simulado] %s\n' "$*"; else "$@"; fi
}

[ "$(uname -s)" = OpenBSD ] || { aviso "Este script e para OpenBSD."; exit 1; }
command -v doas >/dev/null || { aviso "doas nao encontrado. Configure o /etc/doas.conf."; exit 1; }

PACOTES="stow alacritty rofi dunst feh scrot xclip copyq git bash sassc"
APPS="lemonbar-xft firefox nnn zathura zathura-pdf-mupdf mpv vim--no_x11"
JOGOS="supertux supertuxkart"
LAZER="cmatrix tty-clock cowsay figlet sl asciiquarium"
FONTES="cascadia-code noto-emoji noto-cjk"
instalado() { pkg_info -e "${1%%--*}-*" >/dev/null 2>&1; }
instalar()  { rodar doas pkg_add -I "$1"; }

[ -d "$REPO/cwm" ] || { aviso "Repositorio nao encontrado em $REPO."; exit 1; }
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

rodar mkdir -p "$HOME/Downloads" "$HOME/Musica"

# tema GTK da comunidade: Gruvbox-GTK-Theme, amarelo, escuro, contraste medio
msg "Tema GTK: Gruvbox-Yellow-Dark-Medium"
TEMA_SRC="$HOME/.cache/Gruvbox-GTK-Theme"
if command -v git >/dev/null && command -v bash >/dev/null && command -v sassc >/dev/null; then
	if [ -d "$TEMA_SRC/.git" ]; then
		rodar git -C "$TEMA_SRC" pull -q
	else
		rodar git clone -q --depth 1 https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme "$TEMA_SRC"
	fi
	( cd "$TEMA_SRC/themes" 2>/dev/null && rodar bash install.sh -t yellow -c dark --tweaks medium -l ) ||
		aviso "Tema GTK nao instalou (seguindo)"
else
	aviso "Tema GTK pulado: precisa de git, bash e sassc"
fi

# tema do CopyQ (o CopyQ reescreve o copyq.conf, por isso fica fora do stow)
if command -v copyq >/dev/null && [ -f "$REPO/copyq/gruvbox.ini" ]; then
	msg "Tema do CopyQ: Gruvbox amarelo"
	rodar copyq loadTheme "$REPO/copyq/gruvbox.ini" || aviso "CopyQ precisa estar rodando para receber o tema"
fi

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
msg "Rode: startx  (ou entre pelo login grafico, que usa o ~/.xsession)"
