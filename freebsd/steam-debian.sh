#!/bin/sh
# steam-debian.sh -- EXPERIMENTAL: instala e abre a Steam dentro do chroot Debian (/compat/debian).
#
# NAO e o caminho suportado: o suportado e o linuxulator-steam-utils (steam-setup.sh), que traz
# ajustes que o Debian puro nao tem. O ponto mais fragil e o navegador interno da Steam
# (steamwebhelper, um Chromium). Use para experimentar; se nao abrir, o caminho normal continua la.
#
# Pre-requisito: o Debian ja criado com debian-chroot.sh e o usuario 'steam' do steam-setup.sh.
# Uso (como o seu usuario, com sudo):   sudo sh steam-debian.sh
# Teste sem mudar nada:                 DRY_RUN=1 sh steam-debian.sh
set -eu

TARGET="${TARGET:-/compat/debian}"
STEAM_USER="${STEAM_USER:-steam}"
DRY_RUN="${DRY_RUN:-0}"
BIN="${BIN:-/usr/local/bin/steam-debian}"
CHPATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"

say() { printf '\n==> %s\n' "$*"; }

run() { # executa, ou so mostra quando DRY_RUN=1
    if [ "$DRY_RUN" = 1 ]; then printf '   [dry-run] %s\n' "$*"; else "$@"; fi
}

inchroot() { # roda um comando dentro do Debian, como root, sem herdar o ambiente do FreeBSD
    run chroot "$TARGET" /usr/bin/env -i PATH="$CHPATH" TERM="${TERM:-xterm}" \
        DEBIAN_FRONTEND=noninteractive "$@"
}

if [ "$DRY_RUN" != 1 ] && [ "$(id -u)" -ne 0 ]; then
    echo "Rode como root: sudo sh $0" >&2
    exit 1
fi

# --- 0. conferir o que ja deveria existir --------------------------------
if [ "$DRY_RUN" != 1 ]; then
    [ -x "$TARGET/bin/bash" ] || { echo "Nao achei o Debian em $TARGET. Rode debian-chroot.sh antes." >&2; exit 1; }
    pw usershow "$STEAM_USER" >/dev/null 2>&1 || { echo "Usuario '$STEAM_USER' nao existe. Rode steam-setup.sh antes." >&2; exit 1; }
    mount | grep -q "$TARGET/tmp" || echo "AVISO: $TARGET/tmp nao esta montado (nullfs); a Steam nao enxergara o X11. Rode: sudo mount -al"
fi

# --- 1. multiarch i386 (a Steam e um programa de 32 bits) ----------------
say "1. arquitetura i386 e lista de pacotes"
inchroot dpkg --add-architecture i386
inchroot apt-get update

# --- 1b. preparar o chroot (sem systemd) ---------------------------------
# O pacote dbus exige o usuario/grupo 'messagebus', que o systemd criaria; sem eles o dpkg
# para e os ~25 pacotes que dependem do dbus ficam sem configurar. Tambem impede o dpkg
# de tentar iniciar servicos (policy-rc.d) e conserta uma instalacao interrompida antes.
say "1b. usuario messagebus, policy-rc.d e configuracao pendente"
inchroot sh -c "printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d; chmod +x /usr/sbin/policy-rc.d"
inchroot sh -c "getent group messagebus >/dev/null || groupadd -r messagebus; id messagebus >/dev/null 2>&1 || useradd -r -g messagebus -d /nonexistent -s /usr/sbin/nologin messagebus"
inchroot dpkg --configure -a || true

# --- 2. licenca da Steam respondida de antemao ---------------------------
say "2. aceitar a licenca da Steam (debconf)"
if [ "$DRY_RUN" = 1 ]; then
    printf '   [dry-run] debconf-set-selections: steam/question = I AGREE\n'
else
    printf 'steam steam/question select I AGREE\nsteam steam/license note\n' \
        | chroot "$TARGET" /usr/bin/env -i PATH="$CHPATH" debconf-set-selections
fi

# --- 3. Steam e drivers Mesa (AMD) ---------------------------------------
say "3. steam-installer e Mesa (OpenGL/Vulkan, 64 e 32 bits)"
inchroot apt-get install -y steam-installer ca-certificates xdg-utils locales \
    libgl1-mesa-dri libgl1-mesa-dri:i386 libglx-mesa0 libglx-mesa0:i386 \
    mesa-vulkan-drivers mesa-vulkan-drivers:i386
inchroot apt-get -f install -y
inchroot dpkg --configure -a

# --- 4. HOME da Steam dentro do chroot -----------------------------------
say "4. pasta pessoal do $STEAM_USER dentro do Debian"
run mkdir -p "$TARGET/home/$STEAM_USER"
run chown "$STEAM_USER:$STEAM_USER" "$TARGET/home/$STEAM_USER"

# --- 5. atalho steam-debian ---------------------------------------------
say "5. comando steam-debian"
if [ "$DRY_RUN" = 1 ]; then
    printf '   [dry-run] criar %s\n' "$BIN"
else
    cat > "$BIN" <<SH
#!/bin/sh
# abre a Steam do Debian como o usuario $STEAM_USER.
# Antes, no SEU usuario:  xhost +si:localuser:$STEAM_USER
# Se a janela ficar preta ou travar:  steam-debian -no-cef-sandbox -cef-disable-gpu
[ "\$(id -u)" -eq 0 ] || exec sudo "\$0" "\$@"
exec chroot -u $STEAM_USER -g $STEAM_USER $TARGET /usr/bin/env -i \\
    HOME=/home/$STEAM_USER USER=$STEAM_USER LOGNAME=$STEAM_USER \\
    DISPLAY="\${DISPLAY:-:0}" TERM="\${TERM:-xterm}" LANG=C.UTF-8 PATH=$CHPATH \\
    /usr/games/steam "\$@"
SH
    chmod 755 "$BIN"
fi

cat <<EOF

Pronto (experimental). Para abrir:

    xhost +si:localuser:$STEAM_USER        # no seu usuario, uma vez por login
    steam-debian

Se a janela ficar preta ou travar:  steam-debian -no-cef-sandbox -cef-disable-gpu
Se nada funcionar, o caminho suportado e o do steam-setup.sh (usuario '$STEAM_USER', comando 'steam').
EOF
