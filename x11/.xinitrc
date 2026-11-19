#!/bin/sh
# ~/.xinitrc - sessao do cwm no OpenBSD (startx; o ~/.xsession do xenodm le este arquivo)
# O cwm nao tem autostart: o que sobe com a sessao fica aqui.

# barramento D-Bus da sessao (dunst e copyq precisam dele)
if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ] && command -v dbus-launch >/dev/null; then
	eval "$(dbus-launch --sh-syntax --exit-with-session)"
fi

# cores do X (xterm, xclock...) e fundo: o seu ~/.fehbg, ou a cor lisa Tango
[ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"
if [ -x "$HOME/.fehbg" ]; then "$HOME/.fehbg"; else xsetroot -solid "#2e3436"; fi

# notificacoes e area de transferencia
command -v dunst >/dev/null && dunst &
command -v copyq >/dev/null && copyq &

# bloqueio apos 5 min parado; -no desliga o bloqueio pelo canto da tela
[ -x /usr/local/bin/i3lock ] && xidle -no -timeout 300 -program "/usr/local/bin/i3lock -c 2e3436" &

exec cwm
