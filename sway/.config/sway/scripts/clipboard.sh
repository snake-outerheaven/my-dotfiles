#!/bin/sh
# clipboard.sh: historico da area de transferencia (wl-clipboard + cliphist + fuzzel)
#   clipboard.sh          abre o historico no fuzzel e copia o item escolhido
#   clipboard.sh limpar   apaga todo o historico
set -eu
if [ "${1:-}" = "limpar" ]; then
    cliphist wipe
    command -v notify-send >/dev/null && notify-send "Clipboard" "Historico apagado" || true
    exit 0
fi
item="$(cliphist list | fuzzel --dmenu --prompt 'clip  ')" || exit 0   # Esc cancela
[ -n "$item" ] || exit 0
printf '%s\n' "$item" | cliphist decode | wl-copy
