#!/bin/sh
# install.sh - monta o desktop inteiro com cwm flutuante (Tango, amarelo)
# Xenocara primeiro: xterm, xidle e os menus do cwm vem na base;
# rofi (lancador) e i3lock (bloqueio) vem por pacote.
# Feito para o OpenBSD.
#
# Etapas: pacotes, fontes, lazer, pastas do usuario (xdg-user-dirs),
# sistema (xenodm, apmd, classe staff), tema do CopyQ e dotfiles (stow).
#
# Fica no pacote stow "scripts": depois do stow, vira ~/install.sh.
# Uso:
#   sh ~/install.sh       (ou: sh scripts/install.sh, de dentro do repositorio)
#   sh ~/install.sh -n    so mostra o que faria
#
# Nada e apagado: arquivos que atrapalham o stow vao para ~/.dotfiles-backup-DATA.
# As mudancas de sistema (etapa "Sistema") pedem confirmacao antes.

set -u

SIMULAR=0
[ "${1:-}" = "-n" ] && SIMULAR=1

# acha o repositorio mesmo quando rodado pelo link ~/install.sh
SCRIPT=$(readlink -f "$0")
REPO=$(dirname "$(dirname "$SCRIPT")")
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

STOW_PACOTES="dunst rofi tmux x11 xdg cwm scripts zathura mpv cmus vim"

msg()  { printf '\033[33m==>\033[0m %s\n' "$*"; }
aviso(){ printf '\033[31m!!\033[0m %s\n' "$*"; }
rodar() {
	if [ "$SIMULAR" -eq 1 ]; then printf '    [simulado] %s\n' "$*"; else "$@"; fi
}

[ "$(uname -s)" = OpenBSD ] || { aviso "Este script e para OpenBSD."; exit 1; }
command -v doas >/dev/null || { aviso "doas nao encontrado. Configure o /etc/doas.conf."; exit 1; }

PACOTES="stow dunst rofi i3lock feh scrot copyq xdg-user-dirs git"
APPS="firefox ranger htop zathura zathura-pdf-mupdf mpv cmus vim--no_x11"
JOGOS="supertux supertuxkart openttd"
LAZER="cmatrix tty-clock cowsay figlet sl asciiquarium"
FONTES="noto-nerd-fonts noto-emoji noto-cjk"
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

# --- sistema: login grafico, energia e limites de memoria (precisa de doas) ---
perguntar() {
	[ "$SIMULAR" -eq 1 ] && return 0
	printf '\033[33m??\033[0m %s [s/N] ' "$*"
	read -r resp
	case "$resp" in [sS]*) return 0 ;; *) return 1 ;; esac
}

msg "Sistema"
if perguntar "Ativar o login grafico (xenodm) no boot?"; then
	rodar doas rcctl enable xenodm
fi
if perguntar "Ativar o apmd em modo automatico (-A: frequencia da CPU conforme a carga)?"; then
	rodar doas rcctl enable apmd
	rodar doas rcctl set apmd flags -A
	rodar doas rcctl restart apmd
fi
if [ "$(id -nu)" != root ] && ! id -Pn "$(id -nu)" 2>/dev/null | grep -q ':staff:'; then
	if perguntar "Colocar $(id -nu) na classe staff (mais memoria para o Firefox)?"; then
		rodar doas usermod -L staff "$(id -nu)"
		msg "Classe staff vale no proximo login."
	fi
fi

# tema do CopyQ (o CopyQ reescreve o copyq.conf, por isso fica fora do stow)
if command -v copyq >/dev/null && [ -f "$REPO/copyq/tango.ini" ]; then
	msg "Tema do CopyQ: Tango amarelo"
	rodar copyq loadTheme "$REPO/copyq/tango.ini" || aviso "CopyQ precisa estar rodando para receber o tema"
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

# --- pastas do usuario (depois do stow, que instala o ~/.config/user-dirs.dirs) ---
msg "Pastas do usuario (xdg-user-dirs)"
for d in DESKTOP DOCUMENTS DOWNLOAD MUSIC PICTURES VIDEOS TEMPLATES PUBLICSHARE; do
	if [ "$SIMULAR" -eq 1 ]; then
		printf '    [simulado] mkdir -p (xdg-user-dir %s)\n' "$d"
	elif command -v xdg-user-dir >/dev/null; then
		pasta=$(xdg-user-dir "$d")
		[ "$pasta" != "$HOME" ] && mkdir -p "$pasta" && printf '    %s\n' "$pasta"
	fi
done
rodar mkdir -p "$HOME/Imagens/Capturas"

# wallpaper das flores amarelas (Unsplash): baixado, não versionado
if [ ! -f "$HOME/.local/share/wallpapers/flores-amarelas.jpg" ]; then
	msg "Wallpaper: flores amarelas (Unsplash)"
	rodar "$REPO/scripts/.local/bin/pega-wallpaper" || aviso "Sem wallpaper: o fundo fica na cor lisa Tango"
fi

msg "Pronto."
[ -d "$BACKUP" ] && msg "Arquivos antigos guardados em $BACKUP"
msg "Rode: startx  (ou entre pelo login grafico, que usa o ~/.xsession)"
