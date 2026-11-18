#!/bin/sh
# ~/.xinitrc - i3 amarelo Tango no OpenBSD (iniciar com: startx)
# Tudo o que o i3 usa fica em /usr/local/share/bsd-i3 e /usr/local/libexec/bsd-i3.
# Este arquivo e o ~/.xsession sao os unicos que o bsd-i3 poe no seu $HOME.

# barramento D-Bus da sessao: o dunst e o copyq precisam dele
if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ] && command -v dbus-launch >/dev/null; then
	eval "$(dbus-launch --sh-syntax --exit-with-session)"
fi

# notificacoes: sobe aqui, logo depois do D-Bus, para que nenhum aviso
# chegue antes e faca o D-Bus abrir um dunst sem o tema
command -v dunst >/dev/null && dunst -config /usr/local/share/bsd-i3/dunstrc &

# cores do X: as do bsd-i3 e, por cima, as suas (se houver)
xrdb -merge /usr/local/share/bsd-i3/Xresources
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources

exec i3 -c /usr/local/share/bsd-i3/i3.conf
