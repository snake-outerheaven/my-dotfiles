#!/bin/sh
# status.sh: linha de status da swaybar (volume, bateria, data)
# Volume pelo wpctl (PipeWire); se nao tiver, tenta o pactl.
volume() {
    if command -v wpctl >/dev/null; then
        v=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null) || return
        pct=$(printf '%s' "$v" | awk '{printf "%d", $2*100}')
        case "$v" in *MUTED*) printf 'vol mudo' ;; *) printf 'vol %s%%' "$pct" ;; esac
    elif command -v pactl >/dev/null; then
        pct=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk -F/ 'NR==1{gsub(/ /,"",$2); print $2}')
        mudo=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null)
        case "$mudo" in *yes*) printf 'vol mudo' ;; *) [ -n "$pct" ] && printf 'vol %s' "$pct" ;; esac
    fi
}
bateria() {
    for b in /sys/class/power_supply/BAT*; do
        [ -r "$b/capacity" ] || continue
        printf 'bat %s%%' "$(cat "$b/capacity")"
        [ "$(cat "$b/status" 2>/dev/null)" = "Charging" ] && printf '+'
        return
    done
}
while true; do
    linha=""
    for parte in "$(volume)" "$(bateria)" "$(date '+%a %d/%m %H:%M')"; do
        [ -n "$parte" ] && linha="${linha:+$linha  |  }$parte"
    done
    printf ' %s \n' "$linha"
    sleep 2
done
