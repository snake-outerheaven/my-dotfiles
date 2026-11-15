#!/bin/ksh
# install.ksh - monta o desktop ctwm (config da nia, Tango laranja) no NetBSD
#
# Faz uma coisa so: monta o desktop. Nao mexe no sistema (doas.conf,
# login.conf, sysctl.conf, rc.conf, pkgin, rede).
#
# Pre-requisitos (por sua conta):
#   - sets do X instalados (ctwm, uxterm, xclock e a fonte spleen vem neles)
#   - doas (ou sudo) funcionando para o seu usuario
#   - pkgin configurado e "pkgin update" ja rodado
#   - git instalado e este repositorio clonado
#
# Pacotes: listas/*.txt, um por linha, # comenta. Escolha as listas:
#   ksh install.ksh                 todas
#   ksh install.ksh dev dia         so estas
#   ksh install.ksh -n [listas]     so mostra o que faria
#
# Nada e apagado: arquivos (e links de outros setups, como o bsd-i3) que
# atrapalham o stow vao para ~/.dotfiles-backup-DATA.

set -u

REPO=$(cd "$(dirname "$0")" && pwd)
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
TODAS="base fontes apps dev dia mcu lazer"
STOW_PACOTES="ctwm x11 scripts"

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
[[ $(uname -s) = NetBSD ]] || { aviso "Este script e para o NetBSD."; exit 1; }
[[ -x /usr/X11R7/bin/ctwm ]] || falta "ctwm nao encontrado: instale os sets do X (xbase, xserver, xfont)."

if whence -p doas >/dev/null; then PRIV=doas
elif whence -p sudo >/dev/null; then PRIV=sudo
else falta "nem doas nem sudo instalados."
fi
$PRIV true 2>/dev/null || falta "$PRIV nao funciona para $(id -un)."
whence -p pkgin >/dev/null || falta "pkgin nao encontrado."
pkgin avail 2>/dev/null | grep -q '^feh-' ||
	falta "pkgin nao lista pacotes. Rode: $PRIV pkgin update"

msg "NetBSD, desktop ctwm. Repositorio: $REPO"
(( SIMULAR )) && msg "Modo simulacao: nada sera alterado."

instalado() { pkg_info -e "$1-[0-9]*" >/dev/null 2>&1; }

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
			rodar $PRIV pkgin -y install "$p" || aviso "Nao instalou: $p (seguindo)"
		fi
	done
done

# --- dotfiles ---
whence -p stow >/dev/null || (( SIMULAR )) || falta "stow nao instalado (esta na lista base)."
msg "Dotfiles (stow): $STOW_PACOTES"
for pac in $STOW_PACOTES; do
	(cd "$REPO/$pac" && find . -type f) | while read -r f; do
		alvo="$HOME/${f#./}"
		# arquivo comum, ou link de outro setup (ex.: bsd-i3): guarda no backup
		if [[ -L $alvo && $(readlink -f "$alvo" 2>/dev/null) != "$REPO"/* ]] ||
		   [[ -e $alvo && ! -L $alvo ]]; then
			destino="$BACKUP/${f#./}"
			print -- "    backup: $alvo -> $destino"
			rodar mkdir -p "$(dirname "$destino")"
			rodar mv "$alvo" "$destino"
		fi
	done
	rodar stow --no-folding -d "$REPO" -t "$HOME" "$pac" || aviso "stow falhou em $pac"
done

# --- wallpaper ---
if [[ ! -f $HOME/.local/share/wallpapers/flores-laranjas.jpg ]]; then
	msg "Wallpaper: flores laranjas (Unsplash)"
	rodar "$REPO/scripts/.local/bin/pega-wallpaper" ||
		aviso "Nao baixou o wallpaper (seguindo; fica a cor lisa)"
fi

msg "Pronto."
[[ -d $BACKUP ]] && msg "Arquivos antigos guardados em $BACKUP"
msg "Rode: startx"
