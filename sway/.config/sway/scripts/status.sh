#!/bin/sh
# status.sh: linha de status da swaybar (protocolo i3bar em JSON, com cores Gruvbox)
#   volume  | bateria (ou "AC" no desktop sem bateria) | data
# A bateria e procurada por tipo em /sys/class/power_supply (BAT0, BAT1, CMB0...).
# Sem bateria e sem fonte: o modulo simplesmente some.

PS_DIR="${PS_DIR:-/sys/class/power_supply}"   # PS_DIR so muda em teste
FG="#ebdbb2"; VERDE="#b8bb26"; AMARELO="#fabd2f"; VERMELHO="#fb4934"; CINZA="#928374"
avisado=""

bloco() { # nome texto cor
    printf '{"name":"%s","full_text":" %s ","color":"%s","separator_block_width":15}' "$1" "$2" "$3"
}

volume() {
    if command -v wpctl >/dev/null; then
        v=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null) || return 0
        # LC_ALL=C: em pt_BR o awk le "0.45" como 0
        pct=$(printf '%s' "$v" | LC_ALL=C awk '{printf "%d", $2*100 + 0.5}')
        case "$v" in
            *MUTED*) bloco volume "vol mudo" "$CINZA" ;;
            *)       bloco volume "vol ${pct}%" "$FG" ;;
        esac
    elif command -v pactl >/dev/null; then
        pct=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk -F/ 'NR==1{gsub(/ /,"",$2); print $2}')
        [ -n "$pct" ] && bloco volume "vol $pct" "$FG"
    fi
}

# bateria() roda no shell principal (sem $(...)) para lembrar se ja avisou;
# o resultado vai na variavel BAT_OUT
bateria() {
    BAT_OUT=""; bat=""; ac=""
    for d in "$PS_DIR"/*; do
        [ -r "$d/type" ] || continue
        case "$(cat "$d/type")" in
            Battery) [ -r "$d/capacity" ] && [ -z "$bat" ] && bat="$d" ;;
            Mains)   [ "$(cat "$d/online" 2>/dev/null)" = "1" ] && ac=1 ;;
        esac
    done

    if [ -z "$bat" ]; then
        # desktop: sem bateria. Mostra AC se houver fonte detectada; senao, nada
        [ -n "$ac" ] && BAT_OUT=$(bloco bateria "AC" "$CINZA")
        return 0
    fi

    cap=$(cat "$bat/capacity")
    est=$(cat "$bat/status" 2>/dev/null)
    case "$est" in
        Charging)        sinal="+" ;;
        Full|"Not charging") sinal="=" ;;
        *)               sinal="" ;;
    esac
    if   [ "$cap" -le 15 ] && [ "$est" != "Charging" ]; then cor="$VERMELHO"
    elif [ "$cap" -le 30 ]; then cor="$AMARELO"
    else cor="$VERDE"; fi

    # aviso unico quando cai para 10% descarregando
    if [ "$cap" -le 10 ] && [ "$est" = "Discharging" ]; then
        if [ -z "$avisado" ] && command -v notify-send >/dev/null; then
            notify-send -u critical "Bateria baixa" "${cap}%: ligue o carregador" || true
        fi
        avisado=1
    else
        avisado=""
    fi
    BAT_OUT=$(bloco bateria "bat ${cap}%${sinal}" "$cor")
}

data() { bloco data "$(date '+%a %d/%m %H:%M')" "$FG"; }

printf '{"version":1}\n[\n'
while true; do
    linha=""
    bateria
    for b in "$(volume)" "$BAT_OUT" "$(data)"; do
        [ -n "$b" ] && linha="${linha:+$linha,}$b"
    done
    printf '[%s],\n' "$linha"
    sleep 2
done
