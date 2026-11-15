#!/bin/sh
# ~/.xinitrc - ctwm da nia em Tango laranja (NetBSD). Iniciar com: startx
export PATH="$HOME/.local/bin:$PATH"

xrdb -merge "$HOME/.Xresources"

# wallpaper: flores laranjas (feh); sem a foto, cor lisa Tango.
# Roda depois que o ctwm sobe: o ctwm limpa o fundo ao iniciar.
WALL="$HOME/.local/share/wallpapers/flores-laranjas.jpg"
fundo() {
	sleep 2
	if command -v feh >/dev/null 2>&1 && [ -f "$WALL" ]; then
		feh --no-fehbg --bg-fill "$WALL"
	else
		xsetroot -solid '#2e3436'
	fi
}
fundo &

# relogio no canto inferior esquerdo (o ctwmrc deixa ele em todas as areas)
xclock -geometry 100x100+4-4 &

# bateria: barrinha fina no topo da tela (xbattbar, via ACPI/envsys)
command -v xbattbar >/dev/null 2>&1 && xbattbar top &

# area de transferencia com historico
command -v copyq >/dev/null 2>&1 && copyq &

# trava a tela sozinho depois de 5 min parado
command -v xidle >/dev/null 2>&1 && xidle -timeout 300 -program "$HOME/.local/bin/bloqueio" &

uxterm &
exec ctwm
