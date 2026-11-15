#!/bin/ksh
# install.ksh - monta o desktop fvwm (o do base, 2.2.5) em Tango amarelo no OpenBSD
#
# Faz uma coisa so: monta o desktop. Nao mexe no sistema (doas.conf,
# login.conf, installurl, firmware, servicos).
#
# Pre-requisitos (por sua conta):
#   - sets do X instalados (fvwm, xterm, xclock, xlock e as fontes vem neles)
#   - doas funcionando para o seu usuario
#   - mirror valido em /etc/installurl
#   - git instalado e este repositorio clonado
#
# Pacotes: listas/*.txt, um por linha, # comenta.
#   ksh install.ksh               todas as listas
#   ksh install.ksh base          so esta
#   ksh install.ksh -n [listas]   so mostra o que faria
#
# Nada e apagado: arquivos que atrapalham o stow vao para ~/.dotfiles-backup-DATA.

set -u

REPO=$(cd "$(dirname "$0")" && pwd)
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
TODAS="base apps"
STOW_PACOTES="fvwm x11 scripts"

SIMULAR=0
if [[ ${1:-} = -n ]]; then
	SIMULAR=1
	shift
fi
LISTAS=${*:-$TODAS}

msg()   { print -- "\033[33m==>\033[0m $*"; }
aviso() { print -- "\033[31m!!\033[0m $*"; }
falta() { aviso "$1"; aviso "Isso e do sistema: arrume e rode de novo."; exit 1; }
rodar() {
	if (( SIMULAR )); then print -- "    [simulado] $*"; else "$@"; fi
}

# --- sistema: so confere, nunca altera ---
[[ $(uname -s) = OpenBSD ]] || { aviso "Este script e para o OpenBSD."; exit 1; }
[[ -x /usr/X11R6/bin/fvwm ]] || falta "fvwm nao encontrado: instale os sets do X (xbase, xfont, xserv, xshare)."
doas true 2>/dev/null || falta "doas nao funciona para $(id -un). Veja doas.conf(5)."
pkg_info -Q feh >/dev/null 2>&1 ||
	falta "nao achei pacotes no mirror ($(cat /etc/installurl 2>/dev/null)). Veja installurl(5)."

msg "OpenBSD, desktop fvwm. Repositorio: $REPO"
(( SIMULAR )) && msg "Modo simulacao: nada sera alterado."

# tira o flavor (vim--no_x11 -> vim)
instalado() { pkg_info -e "${1%%--*}-*" >/dev/null 2>&1; }

# --- pacotes, lista por lista ---
for lista in $LISTAS; do
	arq="$REPO/listas/$lista.txt"
	if [[ ! -f $arq ]]; then
		aviso "lista desconhecida: $lista (tem: $TODAS)"
		continue
	fi
	pacotes=$(sed -e 's/#.*//' -e 's/[[:space:]]//g' -e '/^$/d' "$arq" | tr '\n' ' ')
	msg "Pacotes ($lista): $pacotes"
	for p in $pacotes; do
		if instalado "$p"; then
			print -- "    $p ja instalado"
		else
			rodar doas pkg_add -I "$p" || aviso "Nao instalou: $p (seguindo)"
		fi
	done
done

# --- dotfiles ---
whence -p stow >/dev/null || (( SIMULAR )) || falta "stow nao instalado (esta na lista base)."
msg "Dotfiles (stow): $STOW_PACOTES"
for pac in $STOW_PACOTES; do
	(cd "$REPO/$pac" && find . -type f) | while read -r f; do
		alvo="$HOME/${f#./}"
		if [[ -e $alvo && ! -L $alvo ]]; then
			destino="$BACKUP/${f#./}"
			print -- "    backup: $alvo -> $destino"
			rodar mkdir -p "$(dirname "$destino")"
			rodar mv "$alvo" "$destino"
		fi
	done
	rodar stow --no-folding -d "$REPO" -t "$HOME" "$pac" || aviso "stow falhou em $pac"
done

# --- wallpaper ---
if [[ ! -f $HOME/.local/share/wallpapers/flores-amarelas.jpg ]]; then
	msg "Wallpaper: flores amarelas (Unsplash)"
	rodar "$REPO/scripts/.local/bin/pega-wallpaper" ||
		aviso "Nao baixou o wallpaper (seguindo; fica a cor lisa)"
fi

msg "Pronto."
[[ -d $BACKUP ]] && msg "Arquivos antigos guardados em $BACKUP"
msg "Rode: startx"
