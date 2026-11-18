#!/bin/sh
# install.sh - instala o desktop i3 amarelo Tango no OpenBSD
#
# Uso (na raiz do repositorio, branch bsd-i3):
#   sh install.sh            instala pacotes, arquivos do sistema e o ~/.xinitrc
#   sh install.sh -n         so mostra o que faria, sem mudar nada
#
# Grupos de programas extras (todos por padrao):
#   GRUPOS="apps jogos lazer fontes"
#   GRUPOS="apps" sh install.sh      so o grupo apps
#   GRUPOS="" sh install.sh          nenhum grupo extra
#
# Perfil da maquina (detectado sozinho pela bateria):
#   notebook   barra com bateria
#   desktop    sem bateria: a bateria some da barra (nada de alerta falso)
#   PERFIL=desktop sh install.sh     forca o perfil (grava em /etc/bsd-i3/perfil)
#
# O que vai para onde:
#   /usr/local/libexec/bsd-i3/     scripts (barra, volume, printar, bloqueio, fundo, perfil-maquina)
#   /usr/local/share/bsd-i3/       i3.conf, modelos do i3status, alacritty, rofi, dunst, copyq, Xresources
#   /etc/bsd-i3/perfil             desktop ou notebook
#   ~/.xinitrc e ~/.xsession       unicos arquivos no $HOME (stow)
# Seus arquivos nunca sao apagados. Do $HOME saem so os links que versoes
# antigas deste repositorio criaram (e as pastas que eles deixarem vazias).
# Arquivos que atrapalham o stow vao para ~/.dotfiles-backup-DATA.
#
# Pre-requisitos (por sua conta): doas configurado (doas.conf(5)),
# mirror em /etc/installurl (installurl(5)), git e este repositorio clonado.

set -u

SIMULAR=0
[ "${1:-}" = "-n" ] && SIMULAR=1

REPO=$(cd "$(dirname "$0")" && pwd)
NOME_REPO=$(basename "$REPO")
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

LIBEXEC=/usr/local/libexec/bsd-i3
SHARE=/usr/local/share/bsd-i3
ETC=/etc/bsd-i3

# essenciais: o desktop nao sobe sem eles (falha para o script)
ESSENCIAIS="i3 i3status i3lock stow rofi alacritty"
# opcionais: falha vira aviso
OPCIONAIS="dunst libnotify copyq feh scrot xdg-user-dirs dbus cascadia-code noto-emoji firefox"
G_APPS="nnn zathura zathura-pdf-mupdf mpv cmus vim--no_x11"
G_JOGOS="supertux supertuxkart openttd"
G_LAZER="cmatrix tty-clock cowsay figlet sl asciiquarium"
G_FONTES="noto-cjk"

# pacotes stow aplicados no $HOME
STOW_PACOTES="x11"

falhas=""

msg()  { printf '\033[33m==>\033[0m %s\n' "$*"; }
aviso(){ printf '\033[31m!!\033[0m %s\n' "$*"; }

rodar() {
	if [ "$SIMULAR" -eq 1 ]; then
		printf '    [simulado] %s\n' "$*"
	else
		"$@"
	fi
}

# grupos extras entram na lista de opcionais (falha vira aviso, como os demais)
GRUPOS="${GRUPOS-apps jogos lazer fontes}"
for g in $GRUPOS; do
	case "$g" in
	apps)   OPCIONAIS="$OPCIONAIS $G_APPS" ;;
	jogos)  OPCIONAIS="$OPCIONAIS $G_JOGOS" ;;
	lazer)  OPCIONAIS="$OPCIONAIS $G_LAZER" ;;
	fontes) OPCIONAIS="$OPCIONAIS $G_FONTES" ;;
	*)      aviso "Grupo desconhecido: $g (use apps, jogos, lazer ou fontes)" ;;
	esac
done

# "nome-[0-9]*": so o pacote com esse nome exato (nao casa libreoffice-i18n-...)
instalado() { pkg_info -e "${1%%--*}-[0-9]*" >/dev/null 2>&1; }
instalar()  { rodar doas pkg_add -I "$1"; }

# 1. conferencias
SO=$(uname -s)
msg "Sistema: $SO"
[ "$SO" = OpenBSD ] || { aviso "Sistema nao suportado: $SO (este setup e so para OpenBSD)."; exit 1; }
command -v doas >/dev/null || { aviso "doas nao encontrado. Configure o /etc/doas.conf (doas.conf(5))."; exit 1; }
for f in share/i3.conf share/i3status-notebook.conf share/i3status-desktop.conf \
    scripts/barra scripts/perfil-maquina x11/.xinitrc; do
	[ -f "$REPO/$f" ] || { aviso "Arvore incompleta: falta $f ao lado do install.sh."; exit 1; }
done
msg "Repositorio: $REPO"
[ "$SIMULAR" -eq 1 ] && msg "Modo simulacao: nada sera alterado."

# 2. pacotes
msg "Instalando pacotes essenciais: $ESSENCIAIS"
for p in $ESSENCIAIS; do
	if instalado "$p"; then
		printf '    %s ja instalado\n' "$p"
	else
		instalar "$p" || { aviso "Falhou: $p (essencial; confira o /etc/installurl)"; exit 1; }
	fi
done

msg "Instalando pacotes opcionais: $OPCIONAIS"
for p in $OPCIONAIS; do
	if instalado "$p"; then
		printf '    %s ja instalado\n' "$p"
	else
		instalar "$p" || { aviso "Nao instalou: $p (seguindo)"; falhas="$falhas $p"; }
	fi
done

# 3. scripts e arquivos do sistema (fora do $HOME)
msg "Instalando scripts em $LIBEXEC e arquivos em $SHARE"
rodar doas install -d -m 755 "$LIBEXEC" "$SHARE" "$ETC" || { aviso "Falha ao criar as pastas do sistema."; exit 1; }
# uma chamada de doas por pasta (menos pedidos de senha sem "persist")
rodar doas install -m 755 "$REPO"/scripts/* "$LIBEXEC/" || { aviso "Falha ao instalar os scripts"; exit 1; }
rodar doas install -m 644 "$REPO"/share/* "$SHARE/" || { aviso "Falha ao instalar os arquivos de $SHARE"; exit 1; }

# 4. perfil da maquina: notebook (com bateria) ou desktop
PERFIL_DETECTADO=$(sh "$REPO/scripts/perfil-maquina" -d)
case "${PERFIL:-}" in
desktop|notebook) PERFIL_FINAL=$PERFIL ;;
'')               PERFIL_FINAL=$PERFIL_DETECTADO ;;
*)                aviso "PERFIL=$PERFIL invalido (use desktop ou notebook); usando o detectado"
                  PERFIL_FINAL=$PERFIL_DETECTADO ;;
esac
msg "Perfil da maquina: $PERFIL_FINAL (detectado: $PERFIL_DETECTADO)"
if [ "$SIMULAR" -eq 1 ]; then
	printf '    [simulado] gravar "%s" em %s/perfil\n' "$PERFIL_FINAL" "$ETC"
else
	echo "$PERFIL_FINAL" | doas tee "$ETC/perfil" >/dev/null || { aviso "Falha ao gravar $ETC/perfil"; exit 1; }
fi

# 5. limpar o que versoes antigas deste repositorio deixaram no $HOME.
# Procura LINKS (nunca arquivos comuns) no formato do stow: um link em
# ~/CAMINHO cujo destino termina em <repo>/<pacote>/CAMINHO, com <repo> igual
# ao nome desta pasta ou a "my-dotfiles". Cobre todas as versoes antigas da
# branch (scripts, i3/config.d, cores, gtk, cwm, picom...), e nao so a ultima.
msg "Removendo links antigos do bsd-i3 no \$HOME (so os que apontam para este repositorio)"
pastas=""
{
	find "$HOME" -maxdepth 1 -type l
	for d in .config .local .tmux .vim bin; do
		[ -d "$HOME/$d" ] && [ ! -L "$HOME/$d" ] && find "$HOME/$d" -type l
	done
} 2>/dev/null | while IFS= read -r alvo; do
	rel=${alvo#"$HOME"/}
	case "$rel" in .xinitrc|.xsession) continue ;; esac
	destino=$(readlink "$alvo") || continue
	case "$destino" in
	*"/$NOME_REPO/"*"/$rel"|"$NOME_REPO/"*"/$rel"|*/my-dotfiles/*"/$rel"|my-dotfiles/*"/$rel") ;;
	*) continue ;;
	esac
	# o pedaco entre <repo>/ e /CAMINHO tem que ser um nome de pacote (sem /)
	resto=${destino%"/$rel"}
	pac=${resto##*/}
	base=${resto%/*}
	case "${base##*/}" in "$NOME_REPO"|my-dotfiles) ;; *) continue ;; esac
	[ -n "$pac" ] || continue
	printf '    %s\n' "$alvo"
	rodar rm "$alvo"
done
# pastas que o stow antigo criou: saem so se ficaram vazias (de dentro para fora).
# Nunca remove o proprio $HOME, ~/.config, ~/.local, ~/.local/share, ~/.local/bin nem ~/bin.
for d in .config/i3/config.d .config/i3 .config/i3status .config/alacritty .config/rofi \
    .config/dunst/dunstrc.d .config/dunst .config/zathura .config/mpv .config/cmus \
    .config/gtk-3.0 .config/gtk-4.0 .config/picom .local/share/copyq-temas \
    .local/share/wallpapers .tmux .vim; do
	[ -d "$HOME/$d" ] && [ ! -L "$HOME/$d" ] || continue
	if [ -z "$(ls -A "$HOME/$d" 2>/dev/null)" ]; then
		rodar rmdir "$HOME/$d"
	fi
done

# 6. dotfiles com stow: so ~/.xinitrc e ~/.xsession.
# Antes de mexer, ve o que atrapalha: arquivo comum ou link que aponta para
# fora deste repositorio vai para ~/.dotfiles-backup-DATA (movido, nunca apagado).
msg "Aplicando no \$HOME: $STOW_PACOTES (.xinitrc e .xsession)"
for pac in $STOW_PACOTES; do
	for f in $(cd "$REPO/$pac" && find . -type f); do
		rel=${f#./}
		alvo="$HOME/$rel"
		if [ -L "$alvo" ]; then
			case "$(readlink "$alvo")" in
			*"$NOME_REPO/$pac/$rel") continue ;;   # ja e nosso
			esac
		elif [ ! -e "$alvo" ]; then
			continue
		fi
		destino="$BACKUP/$rel"
		printf '    backup: %s -> %s\n' "$alvo" "$destino"
		rodar mkdir -p "$(dirname "$destino")" || exit 1
		rodar mv "$alvo" "$destino" || { aviso "Nao consegui mover $alvo; nada foi aplicado."; exit 1; }
	done
	if [ "$SIMULAR" -eq 0 ] && ! stow -n --no-folding -d "$REPO" -t "$HOME" "$pac" 2>/dev/null; then
		aviso "stow ainda ve conflito em $pac; nada foi aplicado."
		[ -d "$BACKUP" ] && aviso "O que foi movido esta em $BACKUP"
		exit 1
	fi
	rodar stow --no-folding -d "$REPO" -t "$HOME" "$pac" || {
		aviso "stow falhou em $pac: o ~/.xinitrc pode estar faltando."
		[ -d "$BACKUP" ] && aviso "O que foi movido esta em $BACKUP"
		exit 1
	}
done

# 7. resumo
msg "Pronto."
[ -n "$falhas" ] && aviso "Pacotes opcionais que nao instalaram:$falhas"
[ "$SIMULAR" -eq 1 ] || [ -x /usr/local/bin/i3lock ] || \
	aviso "i3lock nao encontrado: Super+Shift+x e o bloqueio automatico nao vao funcionar."
fc-list 2>/dev/null | grep -qi "cascadia code" || \
	aviso "Fonte Cascadia Code nao encontrada: instale cascadia-code ou coloque os .ttf em ~/.fonts."
[ -d "$BACKUP" ] && msg "Arquivos antigos guardados em $BACKUP"
msg "Configs de vim, tmux, cmus, mpv e zathura (opcionais): veja extras/ no README"
msg "Bloquear ao suspender (opcional): veja sistema/openbsd/etc/apm/suspend"
msg "Saia da sessao atual e rode: startx"
