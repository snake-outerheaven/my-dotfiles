#!/bin/sh
# install.sh - monta o desktop com i3 (Tango, amarelo, sem barra) e GNU Stow
# Faz uma coisa so: monta o desktop. Funciona no OpenBSD e no NetBSD.
# Nao mexe no sistema (doas.conf, login.conf, mirror, firmware, servicos)
# e segue o idioma do sistema (pastas XDG).
#
# Pre-requisitos (por sua conta, antes de rodar):
#   - doas (ou sudo, no NetBSD) funcionando para o seu usuario
#   - repositorio de pacotes valido
#       OpenBSD: /etc/installurl   (installurl(5))
#       NetBSD:  pkgin configurado e "pkgin update" ja rodado
#   - git instalado e este repositorio clonado
#
# Os pacotes ficam em listas/<sistema>/*.txt: um por linha, # comenta.
#
# Uso:
#   sh scripts/install.sh       (ou: sh ~/install.sh, depois do stow)
#   sh scripts/install.sh -n    so mostra o que faria
#
# Nada e apagado: arquivos que atrapalham o stow vao para ~/.dotfiles-backup-DATA.

set -u

SIMULAR=0
[ "${1:-}" = "-n" ] && SIMULAR=1

# acha o repositorio mesmo quando rodado pelo link ~/install.sh
SCRIPT=$(readlink -f "$0")
REPO=$(dirname "$(dirname "$SCRIPT")")
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

STOW_PACOTES="alacritty dunst rofi tmux x11 i3 scripts zathura mpv cmus vim copyq"
LISTAS="base apps fontes lazer"

msg()  { printf '\033[33m==>\033[0m %s\n' "$*"; }
aviso(){ printf '\033[31m!!\033[0m %s\n' "$*"; }
falta(){ aviso "$1"; aviso "Isso e do sistema: arrume e rode de novo."; exit 1; }
rodar() {
	if [ "$SIMULAR" -eq 1 ]; then printf '    [simulado] %s\n' "$*"; else "$@"; fi
}

# --- sistema: so confere, nunca altera ---
SO=$(uname -s)
case "$SO" in
OpenBSD)
	PRIV=doas
	doas true 2>/dev/null || falta "doas nao funciona para $(id -un). Veja doas.conf(5)."
	pkg_info -Q i3 >/dev/null 2>&1 ||
		falta "nao achei pacotes no mirror ($(cat /etc/installurl 2>/dev/null)). Veja installurl(5)."
	instalar() { rodar "$PRIV" pkg_add -I "$1"; } ;;
NetBSD)
	if command -v doas >/dev/null 2>&1; then PRIV=doas
	elif command -v sudo >/dev/null 2>&1; then PRIV=sudo
	else falta "nem doas nem sudo instalados."; fi
	"$PRIV" true 2>/dev/null || falta "$PRIV nao funciona para $(id -un)."
	command -v pkgin >/dev/null 2>&1 || falta "pkgin nao encontrado."
	pkgin avail 2>/dev/null | grep -q '^i3-' ||
		falta "pkgin nao lista pacotes. Confira o repositorio e rode: $PRIV pkgin update"
	instalar() { rodar "$PRIV" pkgin -y install "$1"; } ;;
*)
	aviso "Este script e para OpenBSD ou NetBSD (este e $SO)."; exit 1 ;;
esac

LISTA_DIR="$REPO/listas/$(echo "$SO" | tr '[:upper:]' '[:lower:]')"
[ -d "$REPO/i3" ] && [ -d "$LISTA_DIR" ] || { aviso "Repositorio incompleto em $REPO."; exit 1; }
msg "Sistema: $SO   Repositorio: $REPO"
[ "$SIMULAR" -eq 1 ] && msg "Modo simulacao: nada sera alterado."

# pkg_info -e funciona nos dois; tira o flavor do OpenBSD (vim--no_x11 -> vim)
instalado() { pkg_info -e "${1%%--*}-*" >/dev/null 2>&1; }

# --- pacotes, lista por lista ---
for lista in $LISTAS; do
	arq="$LISTA_DIR/$lista.txt"
	[ -f "$arq" ] || continue
	pacotes=$(sed -e 's/#.*//' -e 's/[[:space:]]//g' -e '/^$/d' "$arq" | tr '\n' ' ')
	msg "Pacotes ($lista): $pacotes"
	for p in $pacotes; do
		if instalado "$p"; then
			printf '    %s ja instalado\n' "$p"
		else
			instalar "$p" || aviso "Nao instalou: $p (seguindo)"
		fi
	done
done

# --- pastas do usuario (Downloads, Musica...) no idioma do sistema ---
msg "Pastas do usuario: xdg-user-dirs-update"
rodar xdg-user-dirs-update || aviso "xdg-user-dirs-update falhou (seguindo)"

# --- dotfiles ---
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

# --- ajustes por maquina: arquivo vazio, fora do git (o i3 exige que exista) ---
if [ ! -e "$HOME/.config/i3/local.conf" ]; then
	msg "Ajustes desta maquina: ~/.config/i3/local.conf (vazio)"
	rodar mkdir -p "$HOME/.config/i3"
	if [ "$SIMULAR" -eq 1 ]; then printf '    [simulado] criar %s\n' "$HOME/.config/i3/local.conf"
	else printf '# ajustes so desta maquina (fora do git)\n' > "$HOME/.config/i3/local.conf"; fi
fi

# --- wallpaper ---
if [ ! -f "$HOME/.local/share/wallpapers/flores-amarelas.jpg" ]; then
	msg "Wallpaper: flores amarelas (Unsplash)"
	rodar "$REPO/scripts/.local/bin/pega-wallpaper" || aviso "Nao baixou o wallpaper (seguindo; fica a cor lisa)"
fi

msg "Pronto."
[ -d "$BACKUP" ] && msg "Arquivos antigos guardados em $BACKUP"
msg "Rode: startx  (ou entre pelo login grafico, que usa o ~/.xsession)"
