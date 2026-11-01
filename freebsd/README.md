# FreeBSD (máquina `bsd`)

Scripts e notas do desktop com FreeBSD 15.1, XFCE (Xfwm4), ZFS e GPU AMD.
Tudo aqui foi escrito para `sh` do FreeBSD, é idempotente e tem `DRY_RUN=1` para só mostrar o que faria.

| Arquivo | Para quê | Como usar |
|---|---|---|
| `steam-setup.sh` | Prepara a Steam do `linuxulator-steam-utils` (sysctls, nullfs, fstab do `/compat/linux`, usuário `steam`, bootstrap) | `sudo sh steam-setup.sh` |
| `debian-chroot.sh` | Cria um Debian 13 em `/compat/debian` com `debootstrap`, monta o fstab, escreve o `sources.list` e cria o comando `debian` | `sudo sh debian-chroot.sh` |
| `steam-debian.sh` | **Experimental.** Instala e abre a Steam dentro do chroot Debian (comando `steam-debian`) | `sudo sh steam-debian.sh` |
| `xfce4-terminal/Gruvbox-Dark.theme` | Tema de cores do xfce4-terminal | copiar para `~/.local/share/xfce4/terminal/colorschemes/` |

Ordem: `steam-setup.sh` → (opcional) `debian-chroot.sh` → (opcional) `steam-debian.sh`.

## Steam suportada (`steam-setup.sh`)

Depois do script, abrir a Steam exige a sua sessão gráfica liberada para o usuário `steam`:

```sh
xhost +si:localuser:steam     # no seu usuário, uma vez por login
sudo su - steam
export DISPLAY=:0
steam
```

## O que aprendemos (problemas reais)

| Sintoma | Causa | Correção |
|---|---|---|
| `steam` pede "FreeBSD interface names must be enabled" | A Steam exige nomes reais de interface | `sysctl compat.linux.use_real_ifnames=1` e gravar em `/etc/sysctl.kld.d/linux.conf` |
| `sudo` pede senha no usuário `steam` | Ele não é `wheel`, de propósito | Rodar os comandos de administração no seu usuário |
| `su - steam` pede senha que não existe | `pw useradd` sem `-h` deixa a conta sem senha | `sudo su - steam` ou `sudo passwd steam` |
| A Steam não abre a janela | `/tmp` não estava montado dentro de `/compat/linux`, e o socket do X11 fica em `/tmp/.X11-unix` | Linha `nullfs` do `/tmp` no fstab e `mount -al` |
| Erro de display / autorização | O usuário `steam` não tinha permissão na tela | `xhost +si:localuser:steam` |

## Estado dos testes

- Sintaxe e `DRY_RUN` testados no Linux. A lógica de arquivos (fstab sem duplicar, `sources.list`, atalhos) foi testada em diretórios falsos.
- Rodado de verdade no FreeBSD: os sysctls, o nullfs, o usuário `steam` e o bootstrap da Steam.
- **Não** rodado de verdade: `debian-chroot.sh` completo e `steam-debian.sh`. O `steam-debian.sh` é um experimento: o navegador interno da Steam (steamwebhelper) costuma ser o ponto frágil no linuxulator, e o caminho suportado é o `steam-setup.sh`.
