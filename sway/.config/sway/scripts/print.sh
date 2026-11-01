#!/bin/sh
# print.sh: print da tela inteira (padrao) ou de uma area ("area"), com grim + slurp
# Salva em ~/Imagens/Printscreens e copia para a area de transferencia
set -eu
dir="$HOME/Imagens/Printscreens"
mkdir -p "$dir"
arq="$dir/$(date +%Y-%m-%d-%H%M%S).png"
if [ "${1:-}" = "area" ]; then
    geo="$(slurp)" || exit 0          # Esc cancela a selecao
    grim -g "$geo" "$arq"
else
    grim "$arq"
fi
command -v wl-copy >/dev/null && wl-copy --type image/png < "$arq" || true
command -v notify-send >/dev/null && notify-send "Print salvo" "$arq" || true
