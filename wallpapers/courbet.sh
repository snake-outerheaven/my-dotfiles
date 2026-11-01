#!/bin/sh
# courbet.sh: baixa quadros do Gustave Courbet (dominio publico) do Wikimedia Commons
# Uso: sh wallpapers/courbet.sh            -> salva em ~/Imagens/wallpapers/courbet/
# Precisa de: wget e jq
set -eu

DEST="$HOME/Imagens/wallpapers/courbet"
API="https://commons.wikimedia.org/w/api.php"
# O Wikimedia pede um User-Agent com nome e contato
UA="my-dotfiles-wallpapers/1.0 (https://github.com/snake-outerheaven/my-dotfiles)"
mkdir -p "$DEST"

# nome-local | arquivo no Commons
LISTA='natureza-morta-macas-e-pera|Courbet - Still Life with Apples and a Pear, 1871.jpg
natureza-morta-macas-pera-romas|Courbet Still Life with Apples Pear and Pomegranates DMA.jpg
macas-peras-e-primulas|'"'"'Apples, Pears, and Primroses on a Table'"'"' by Gustave Courbet.JPG
macas-peras-e-uvas|Courbet - Apples, Pears, and Grapes on a Table, ca. 1871-1873, 2011.96.jpg
riacho-do-poco-negro|Gustave Courbet - The Stream of the Black Well - Walters 37203.jpg
o-riacho-aberdeen|Gustave Courbet (1819-1877) - The Stream - ABDAG003054 - Aberdeen Art Gallery.jpg
corcas-no-riacho|'"'"'Roe Deer at a Stream'"'"', oil on canvas painting by Gustave Courbet.jpg
a-onda|La Vague, Gustave Courbet.jpg
a-onda-utrecht|The Wave by Gustave Courbet Centraal Museum 22124.jpg'

ok=0; falha=0
tmp=$(mktemp); trap 'rm -f "$tmp" "$tmp.l"' EXIT
printf '%s\n' "$LISTA" > "$tmp.l"
while IFS='|' read -r nome arq; do
    if ls "$DEST/$nome".* >/dev/null 2>&1; then echo "ja existe: $nome"; ok=$((ok+1)); continue; fi
    t=$(jq -rn --arg t "File:$arq" '$t|@uri')
    # pede a versao com 3840 px de largura (ou a original, se for menor)
    if ! wget -q -U "$UA" -O "$tmp" "$API?action=query&format=json&prop=imageinfo&iiprop=url&iiurlwidth=3840&titles=$t"; then
        echo "FALHOU (api): $nome"; falha=$((falha+1)); continue
    fi
    url=$(jq -r '.query.pages[].imageinfo[0] | (.thumburl // .url) // empty' "$tmp" 2>/dev/null || true)
    if [ -z "$url" ]; then echo "NAO ACHEI no Commons: $arq"; falha=$((falha+1)); continue; fi
    ext=$(printf '%s' "${url##*.}" | tr 'A-Z' 'a-z')
    if wget -q -U "$UA" -O "$DEST/$nome.$ext" "$url"; then
        echo "ok: $nome.$ext"; ok=$((ok+1))
    else
        rm -f "$DEST/$nome.$ext"; echo "FALHOU (download): $nome"; falha=$((falha+1))
    fi
    sleep 1
done < "$tmp.l"

echo "pronto: $ok ok, $falha falharam -> $DEST"
echo "para usar um: ~/.config/sway/scripts/wall.sh $DEST/a-onda.jpg"
