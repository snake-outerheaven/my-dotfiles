#!/bin/sh
# steam-setup.sh -- prepara a Steam no FreeBSD (linuxulator-steam-utils).
# Segue a mensagem do pacote: sysctls, nullfs, usuario dedicado nao-wheel, bootstrap.
#
# Uso (como o seu usuario, com sudo):   sudo sh steam-setup.sh
# Teste sem mudar nada:                 DRY_RUN=1 sh steam-setup.sh
# Com Proton nativo (opcional):         sudo PROTON=1 sh steam-setup.sh
# E idempotente: pode rodar de novo sem duplicar nada.
set -eu

STEAM_USER="${STEAM_USER:-steam}"
LSU="/usr/local/steam-utils/bin/lsu-bootstrap"
DRY_RUN="${DRY_RUN:-0}"

say() { printf '\n==> %s\n' "$*"; }

run() { # executa, ou so mostra quando DRY_RUN=1
    if [ "$DRY_RUN" = 1 ]; then printf '   [dry-run] %s\n' "$*"; else "$@"; fi
}

if [ "$DRY_RUN" != 1 ] && [ "$(id -u)" -ne 0 ]; then
    echo "Rode como root: sudo sh $0" >&2
    exit 1
fi

# --- 0. o pacote precisa estar instalado -------------------------------
if [ "$DRY_RUN" != 1 ] && [ ! -x "$LSU" ]; then
    echo "Nao achei $LSU." >&2
    echo "Instale o pacote da Steam primeiro. Para achar o nome: pkg search steam-utils" >&2
    exit 1
fi

# --- 1. sysctls (agora e no boot) --------------------------------------
say "1. sysctls: unprivileged_chroot e usermount"
run sysctl security.bsd.unprivileged_chroot=1
run sysctl vfs.usermount=1
for kv in security.bsd.unprivileged_chroot=1 vfs.usermount=1; do
    if [ "$DRY_RUN" = 1 ]; then
        printf '   [dry-run] garantir %s em /etc/sysctl.conf\n' "$kv"
    elif ! grep -qx "$kv" /etc/sysctl.conf 2>/dev/null; then
        echo "$kv" >> /etc/sysctl.conf
    fi
done

# --- 2. nullfs ----------------------------------------------------------
say "2. nullfs: carregar agora e no boot"
if [ "$DRY_RUN" = 1 ] || ! kldstat -qm nullfs; then run kldload nullfs; fi
run sysrc kld_list+="nullfs"

# --- compatibilidade Linux (a Steam usa o linuxulator) ------------------
say "   compatibilidade Linux: ativar o servico"
run sysrc linux_enable="YES"
run service linux start || true     # ja ativo nao e erro
# a Steam exige nomes reais de interface de rede (le a regra no proprio 'steam')
run sysctl compat.linux.use_real_ifnames=1
run mkdir -p /etc/sysctl.kld.d
if [ "$DRY_RUN" = 1 ]; then
    printf '   [dry-run] garantir compat.linux.use_real_ifnames=1 em /etc/sysctl.kld.d/linux.conf\n'
elif ! grep -qx 'compat.linux.use_real_ifnames=1' /etc/sysctl.kld.d/linux.conf 2>/dev/null; then
    echo 'compat.linux.use_real_ifnames=1' >> /etc/sysctl.kld.d/linux.conf
fi

# --- montagens do /compat/linux no fstab -------------------------------
say "   fstab: sistemas de arquivos do /compat/linux"
if [ "$DRY_RUN" = 1 ]; then
    printf '   [dry-run] acrescentar as montagens do /compat/linux em /etc/fstab (com backup)\n'
    printf '   [dry-run] mount -al\n'
elif grep -q 'linprocfs' /etc/fstab 2>/dev/null; then
    echo "   /etc/fstab ja tem as montagens do linuxulator; nao mexi no arquivo"
    mkdir -p /compat/linux/dev/shm /compat/linux/dev/fd /compat/linux/proc /compat/linux/sys /compat/linux/tmp
    mount -al || true
else
    # os pontos de montagem precisam existir (sem /compat/linux/tmp o 'mount -al' falha e a Steam nao ve o X11)
    mkdir -p /compat/linux/dev/shm /compat/linux/dev/fd /compat/linux/proc /compat/linux/sys /compat/linux/tmp
    cp /etc/fstab "/etc/fstab.bak.$(date +%Y%m%d%H%M%S)"
    cat >> /etc/fstab <<'FSTAB'

# Compatibilidade Linux (Steam)
devfs      /compat/linux/dev      devfs      rw,late                     0 0
tmpfs      /compat/linux/dev/shm  tmpfs      rw,late,size=1g,mode=1777   0 0
fdescfs    /compat/linux/dev/fd   fdescfs    rw,late,linrdlnk            0 0
linprocfs  /compat/linux/proc     linprocfs  rw,late                     0 0
linsysfs   /compat/linux/sys      linsysfs   rw,late                     0 0
/tmp       /compat/linux/tmp      nullfs     rw,late                     0 0
FSTAB
    mount -al || true
fi

# --- 3. usuario dedicado, fora do grupo wheel ---------------------------
say "3. usuario dedicado: $STEAM_USER"
if [ "$DRY_RUN" != 1 ] && pw usershow "$STEAM_USER" >/dev/null 2>&1; then
    echo "   $STEAM_USER ja existe"
else
    run pw useradd -n "$STEAM_USER" -m -s /bin/sh -c "Steam" -G video
fi
run pw groupmod video -m "$STEAM_USER" || true   # ja no grupo nao e erro

# --- 4. bootstrap da Steam (como o usuario dedicado) --------------------
say "4. bootstrap: baixando o executavel da Steam como $STEAM_USER"
run su - "$STEAM_USER" -c "$LSU"

# --- 4b. (opcional) Proton nativo: wine-proton + libs de 32 bits -----------
# Semi-experimental. Ligue com:  sudo PROTON=1 sh steam-setup.sh
if [ "${PROTON:-0}" = 1 ]; then
    say "4b. Proton nativo: wine-proton, libc6-shim, python3 e a parte de 32 bits"
    run pkg install -y wine-proton libc6-shim python3
    run /usr/local/wine-proton/bin/pkg32.sh install wine-proton mesa-dri
    echo "   Na Steam: instale o Proton 8.0 (appid 2348590) ou 9.0 (appid 2805730);"
    echo "   no jogo: Propriedades > Compatibilidade > FreeBSD Wine (emulators/wine-proton)"
fi

# --- 5. falta so abrir a janela ----------------------------------------
say "Pronto. Falta o passo grafico (o usuario $STEAM_USER precisa abrir janelas na sua sessao)."
cat <<EOF

  No terminal do SEU usuario (nao root), uma vez por login:
      xhost +si:localuser:$STEAM_USER

  Depois, entre no usuario da Steam e abra:
      su - $STEAM_USER
      export DISPLAY=:0
      steam

  Se o 'steam' reclamar do linuxulator, reinicie uma vez e tente de novo.
EOF
