#!/bin/sh
# ~/.xinitrc - fvwm do base do OpenBSD, Tango amarelo. Iniciar com: startx
export PATH="$HOME/.local/bin:$PATH"
xrdb -merge "$HOME/.Xresources"
exec fvwm
