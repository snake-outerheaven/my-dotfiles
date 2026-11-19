#!/bin/sh
# install.sh - monta o desktop cwm flutuante, Tango amarelo, no OpenBSD
#
# Uso (na raiz do repositorio, branch openbsd-cwm):
#   sh install.sh            instala pacotes, arquivos do sistema e os dotfiles
#   sh install.sh -n         so mostra o que faria, sem mudar nada
#
# Grupos de programas extras (todos por padrao):
#   GRUPOS="apps jogos lazer fontes"
#   GRUPOS="apps" sh install.sh      so o grupo apps
#   GRUPOS="" sh install.sh          nenhum grupo extra
#
# Perfil da maquina (detectado pela bateria):
#   notebook   o Super+i mostra a bateria
#   desktop    sem bateria no Super+i (nada de "BAT 0%" falso)
#   PERFIL=desktop sh install.sh     forca o perfil (grava em /etc/openbsd-cwm/perfil)
#
# O que vai para onde:
#   /usr/local/libexec/openbsd-cwm/   scripts (cwm-session, fundo, infos, midia, printar, lazer, perfil-maquina)
#   /usr/local/share/openbsd-cwm/     dunstrc, rofi.rasi, copyq-tango.ini
#   /etc/openbsd-cwm/perfil           desktop ou notebook
#   ~/.xinitrc ~/.xsession            sessao (stow, pacote x11)
#   ~/.cwmrc ~/.Xresources            seus para editar (stow, pacotes cwm e x11)
# Nada no ~/bin. Nenhum arquivo seu e apagado: o que atrapalha o stow vai para
# ~/.dotfiles-backup-DATA. Do $HOME saem so links que versoes antigas deste
# repositorio criaram e que agora apontam para o vazio.
#
# Fora do escopo (faca a mao, veja o README): xenodm no boot, apmd -A,
# classe de login, /etc/apm/suspend.
#
# Pre-requisitos: doas configurado (doas.conf(5)), mirror em /etc/installurl,
# git e este repositorio clonado.

set -u

SIMULAR=0
[ "${1:-}" = "-n" ] && SIMULAR=1

REPO=$(cd "$(dirname "$0")" && pwd)
NOME_REPO=$(basename "$REPO")
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

LIBEXEC=/usr/local/libexec/openbsd-cwm
SHARE=/usr/local/share/openbsd-cwm
ETC=/etc/openbsd-cwm

# essenciais: sem eles o lancador, o bloqueio ou o stow nao funcionam (falha para o script)
ESSENCIAIS="rofi i3lock dunst stow"
# opcionais: falha vira aviso
OPCIONAIS="libnotify copyq feh scrot xdg-user-dirs dbus noto-nerd-fonts git firefox"
G_APPS="ranger htop zathura zathura-pdf-mupdf mpv cmus vim--no_x11"
G_JOGOS="supertux supertuxkart openttd"
G_LAZER="cmatrix tty-clock cowsay figlet sl asciiquarium"
G_FONTES="noto-emoji noto-cjk"

# pacotes stow aplicados no $HOME
STOW_PACOTES="x11 cwm"
# pacotes opcionais (so com stow manual), em extras/
EXTRAS="vim tmux cmus mpv zathura xdg"

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

# "nome-[0-9]*": so o pacote com esse nome exato (nao casa nome-outra-coisa)
instalado() { pkg_info -e "${1%%--*}-[0-9]*" >/dev/null 2>&1; }
instalar()  { rodar doas pkg_add -I "$1"; }

# 1. conferencias
SO=$(uname -s)
msg "Sistema: $SO"
[ "$SO" = OpenBSD ] || { aviso "Sistema nao suportado: $SO (este setup e so para OpenBSD)."; exit 1; }
command -v doas >/dev/null || { aviso "doas nao encontrado. Configure o /etc/doas.conf (doas.conf(5))."; exit 1; }
for f in cwm/.cwmrc x11/.xinitrc x11/.xsession x11/.Xresources \
    scripts/cwm-session scripts/perfil-maquina share/dunstrc share/rofi.rasi; do
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

# 3. scripts e arquivos do sistema (fora do $HOME); uma chamada de doas por pasta
msg "Instalando scripts em $LIBEXEC e arquivos em $SHARE"
rodar doas install -d -m 755 "$LIBEXEC" "$SHARE" "$ETC" || { aviso "Falha ao criar as pastas do sistema."; exit 1; }
rodar doas install -m 755 "$REPO"/scripts/* "$LIBEXEC/" || { aviso "Falha ao instalar os scripts."; exit 1; }
rodar doas install -m 644 "$REPO"/share/* "$SHARE/" || { aviso "Falha ao instalar os arquivos de $SHARE."; exit 1; }

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

# 5. links que versoes antigas deste repositorio deixaram no $HOME.
# So mexe em LINKS (nunca em arquivos comuns) no formato do stow: um link em
# ~/CAMINHO cujo destino termina em <repo>/<pacote>/CAMINHO, com <repo> igual
# ao nome desta pasta ou a "my-dotfiles".
#   - se o arquivo ainda existe no repo, o link fica (ex.: ~/.cwmrc);
#   - se ele foi para extras/<pacote>/CAMINHO (vim, tmux...), o link e
#     refeito para la, e a sua config continua funcionando;
#   - se ele foi para o sistema (scripts, dunst, rofi, copyq), o link sai.
msg "Conferindo links antigos do repositorio no \$HOME"
refazer=""
lista=$(
	{
		find "$HOME" -maxdepth 1 -type l
		for d in .config .local .tmux .vim bin; do
			[ -d "$HOME/$d" ] && [ ! -L "$HOME/$d" ] && find "$HOME/$d" -type l
		done
	} 2>/dev/null
)
while IFS= read -r alvo; do
	[ -n "$alvo" ] || continue
	rel=${alvo#"$HOME"/}
	destino=$(readlink "$alvo") || continue
	case "$destino" in
	*"/$NOME_REPO/"*"/$rel"|"$NOME_REPO/"*"/$rel"|*/my-dotfiles/*"/$rel"|my-dotfiles/*"/$rel") ;;
	*) continue ;;
	esac
	resto=${destino%"/$rel"}
	pac=${resto##*/}
	base=${resto%/*}
	case "${base##*/}" in "$NOME_REPO"|my-dotfiles) ;; *) continue ;; esac
	[ -n "$pac" ] || continue
	[ -e "$REPO/$pac/$rel" ] && continue          # ainda vale
	if [ -e "$REPO/extras/$pac/$rel" ]; then
		printf '    %s -> extras/%s\n' "$alvo" "$pac"
		case " $refazer " in *" $pac "*) ;; *) refazer="$refazer $pac" ;; esac
	else
		printf '    removendo %s (agora fica no sistema)\n' "$alvo"
	fi
	rodar rm "$alvo"
done <<LISTA
$lista
LISTA
for pac in $refazer; do
	rodar stow --no-folding -d "$REPO/extras" -t "$HOME" "$pac" || aviso "stow falhou em extras/$pac"
done
# pastas que so os links antigos usavam: saem se ficaram vazias
for d in .config/dunst .config/rofi .local/share/copyq-temas .local/share/wallpapers; do
	[ -d "$HOME/$d" ] && [ ! -L "$HOME/$d" ] || continue
	[ -z "$(ls -A "$HOME/$d" 2>/dev/null)" ] && rodar rmdir "$HOME/$d"
done

# 6. dotfiles com stow. Antes de mexer, o que atrapalha (arquivo comum ou link
# para fora deste repositorio) vai para o backup: movido, nunca apagado.
msg "Aplicando no \$HOME: $STOW_PACOTES (.xinitrc, .xsession, .Xresources, .cwmrc)"
for pac in $STOW_PACOTES; do
	for f in $(cd "$REPO/$pac" && find . -type f); do
		rel=${f#./}
		alvo="$HOME/$rel"
		if [ -L "$alvo" ]; then
			case "$(readlink "$alvo")" in
			*"$NOME_REPO/$pac/$rel") continue ;;   # ja e deste repositorio
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
		aviso "stow falhou em $pac."
		[ -d "$BACKUP" ] && aviso "O que foi movido esta em $BACKUP"
		exit 1
	}
done

# 7. resumo
msg "Pronto."
[ -n "$falhas" ] && aviso "Pacotes opcionais que nao instalaram:$falhas"
[ "$SIMULAR" -eq 1 ] || [ -x /usr/local/bin/i3lock ] || \
	aviso "i3lock nao encontrado: Super+Shift+x e o bloqueio automatico nao vao funcionar."
fc-list 2>/dev/null | grep -qi "NotoSansM Nerd Font" || \
	aviso "Fonte NotoSansM Nerd Font nao encontrada: o cwm, o xterm e o rofi usam uma fonte substituta."
[ -d "$BACKUP" ] && msg "Arquivos antigos guardados em $BACKUP"
msg "Configs opcionais ($EXTRAS): stow --no-folding -d $REPO/extras -t ~ <nome>"
msg "xenodm, apmd, classe de login e bloqueio ao suspender: veja o README (feito a mao)."
msg "Saia da sessao atual e rode: startx  (ou entre pelo xenodm)"
