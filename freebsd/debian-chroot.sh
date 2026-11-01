#!/bin/sh
# debian-chroot.sh -- cria um Debian (debootstrap) em /compat/debian no FreeBSD, pelo linuxulator.
# Fica SEPARADO do /compat/linux, que e o ambiente da Steam.
#
# Uso (como o seu usuario, com sudo):   sudo sh debian-chroot.sh
# Teste sem mudar nada:                 DRY_RUN=1 sh debian-chroot.sh
# Opcoes por variavel de ambiente:      SUITE=trixie  TARGET=/compat/debian  NO_GPG=1
# E idempotente: se o Debian ja existe, so confere fstab, montagens e o atalho 'debian'.
set -eu

SUITE="${SUITE:-trixie}"
TARGET="${TARGET:-/compat/debian}"
NO_GPG="${NO_GPG:-0}"
DRY_RUN="${DRY_RUN:-0}"
FSTAB="${FSTAB:-/etc/fstab}"                 # so muda em teste
RESOLV="${RESOLV:-/etc/resolv.conf}"
BIN="${BIN:-/usr/local/bin/debian}"

say() { printf '\n==> %s\n' "$*"; }

run() { # executa, ou so mostra quando DRY_RUN=1
    if [ "$DRY_RUN" = 1 ]; then printf '   [dry-run] %s\n' "$*"; else "$@"; fi
}

if [ "$DRY_RUN" != 1 ] && [ "$(id -u)" -ne 0 ]; then
    echo "Rode como root: sudo sh $0" >&2
    exit 1
fi

# --- 1. linuxulator ativo (sem ele o chroot nao executa binarios Linux) --
say "1. compatibilidade Linux"
run sysrc linux_enable="YES"
run service linux start || true     # ja ativo nao e erro
run sysrc kld_list+="nullfs"
if [ "$DRY_RUN" = 1 ] || ! kldstat -qm nullfs; then run kldload nullfs; fi

# --- 2. debootstrap ------------------------------------------------------
say "2. pacote debootstrap"
if [ "$DRY_RUN" = 1 ] || ! command -v debootstrap >/dev/null 2>&1; then
    run pkg install -y debootstrap
else
    echo "   debootstrap ja instalado"
fi

# --- 3. criar o Debian ---------------------------------------------------
say "3. criando o Debian $SUITE em $TARGET (demora; baixa uns 300 MB)"
if [ "$DRY_RUN" != 1 ] && [ -x "$TARGET/bin/bash" ]; then
    echo "   $TARGET ja tem um sistema; nao recriei"
else
    run mkdir -p "$TARGET"
    if [ "$NO_GPG" = 1 ]; then
        echo "   AVISO: NO_GPG=1, as assinaturas dos pacotes NAO serao verificadas"
        run debootstrap --arch=amd64 --no-check-gpg "$SUITE" "$TARGET"
    else
        run debootstrap --arch=amd64 "$SUITE" "$TARGET" || {
            echo "" >&2
            echo "debootstrap falhou. Se a mensagem fala de chaves/keyring, rode de novo com:" >&2
            echo "    sudo NO_GPG=1 sh $0     (menos seguro: nao verifica assinaturas)" >&2
            exit 1
        }
    fi
fi

# --- 4. montagens do chroot no fstab -------------------------------------
say "4. fstab: sistemas de arquivos de $TARGET"
if [ "$DRY_RUN" = 1 ]; then
    printf '   [dry-run] acrescentar as montagens de %s em %s (com backup)\n' "$TARGET" "$FSTAB"
    printf '   [dry-run] mount -al\n'
elif grep -q "$TARGET/proc" "$FSTAB" 2>/dev/null; then
    echo "   $FSTAB ja tem as montagens de $TARGET; nao mexi"
else
    mkdir -p "$TARGET/dev/shm" "$TARGET/dev/fd" "$TARGET/proc" "$TARGET/sys" "$TARGET/tmp"
    cp "$FSTAB" "$FSTAB.bak.$(date +%Y%m%d%H%M%S)"
    cat >> "$FSTAB" <<FSTAB

# Debian chroot ($TARGET)
devfs      $TARGET/dev      devfs      rw,late                     0 0
tmpfs      $TARGET/dev/shm  tmpfs      rw,late,size=1g,mode=1777   0 0
fdescfs    $TARGET/dev/fd   fdescfs    rw,late,linrdlnk            0 0
linprocfs  $TARGET/proc     linprocfs  rw,late                     0 0
linsysfs   $TARGET/sys      linsysfs   rw,late                     0 0
/tmp       $TARGET/tmp      nullfs     rw,late                     0 0
FSTAB
    mount -al || true
fi

# --- 4b. repositorios do apt (sources.list) ------------------------------
say "   apt: repositorios do Debian $SUITE"
SRC="$TARGET/etc/apt/sources.list"
if [ "$DRY_RUN" = 1 ]; then
    printf '   [dry-run] escrever %s (main contrib non-free non-free-firmware, updates e security)\n' "$SRC"
elif ls "$TARGET"/etc/apt/sources.list.d/*.sources >/dev/null 2>&1; then
    echo "   ja existe um arquivo .sources em sources.list.d; nao mexi"
elif grep -q "$SUITE-security" "$SRC" 2>/dev/null; then
    echo "   $SRC ja tem os repositorios; nao mexi"
else
    mkdir -p "$TARGET/etc/apt"
    [ -f "$SRC" ] && cp "$SRC" "$SRC.bak"
    cat > "$SRC" <<SOURCES
deb http://deb.debian.org/debian $SUITE main contrib non-free non-free-firmware
deb http://deb.debian.org/debian $SUITE-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security $SUITE-security main contrib non-free non-free-firmware
SOURCES
fi

# --- 5. rede e atalho ----------------------------------------------------
say "5. rede e o comando 'debian'"
if [ "$DRY_RUN" = 1 ]; then
    printf '   [dry-run] copiar /etc/resolv.conf para %s/etc/\n' "$TARGET"
    printf '   [dry-run] criar /usr/local/bin/debian\n'
else
    cp "$RESOLV" "$TARGET/etc/resolv.conf"
    cat > "$BIN" <<SH
#!/bin/sh
# entra no Debian: 'debian' abre um shell; 'debian comando args' roda um comando
[ "\$(id -u)" -eq 0 ] || exec sudo "\$0" "\$@"
cp $RESOLV $TARGET/etc/resolv.conf 2>/dev/null
if [ \$# -eq 0 ]; then
    exec chroot $TARGET /usr/bin/env -i HOME=/root TERM="\$TERM" \\
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash -l
else
    exec chroot $TARGET /usr/bin/env -i HOME=/root TERM="\$TERM" \\
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin "\$@"
fi
SH
    chmod 755 "$BIN"
fi

# --- 6. teste ------------------------------------------------------------
say "6. teste: apt update dentro do Debian"
if [ "$DRY_RUN" = 1 ]; then
    printf '   [dry-run] chroot %s apt-get update\n' "$TARGET"
else
    chroot "$TARGET" /usr/bin/env -i PATH=/usr/sbin:/usr/bin:/sbin:/bin apt-get update \
        || echo "   apt update falhou: confira a rede e o /etc/resolv.conf dentro do chroot"
fi

cat <<EOF

Pronto. Para entrar:   debian
Para rodar um comando: debian apt install build-essential
EOF
