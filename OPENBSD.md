# i3 no OpenBSD (branch `openbsd`)

Port da config do i3 para o OpenBSD, com as áreas em algarismos romanos (I a X).

## Instalação (GNU Stow)

Cada pasta é um pacote do stow e espelha o `$HOME`:

| Pacote | Vira |
|---|---|
| `i3` | `~/.config/i3/config` |
| `i3status` | `~/.config/i3status/config` |
| `alacritty` | `~/.config/alacritty/alacritty.toml` |
| `dunst` | `~/.config/dunst/dunstrc` |
| `picom` | `~/.config/picom/picom.conf` |
| `rofi` | `~/.config/rofi/config.rasi` |
| `tmux` | `~/.tmux.conf` |
| `x11` | `~/.xinitrc` (`exec i3`) e `~/.xsession` (xenodm) |

Automático:

```sh
git clone -b openbsd https://github.com/snake-outerheaven/my-dotfiles
cd my-dotfiles
sh install.sh -n    # simulação
sh install.sh       # instala pacotes e aplica tudo com stow
startx
```

Na mão:

```sh
doas pkg_add stow i3 i3status i3lock alacritty rofi dunst picom feh scrot
stow --no-folding i3 i3status alacritty dunst picom rofi tmux x11
```

`xidle`, `xbacklight` e `sndioctl` já vêm na base do OpenBSD. Arquivos que já existirem no `$HOME` impedem o stow; o `install.sh` move esses para `~/.dotfiles-backup-DATA` antes.

## O que mudou em relação ao Linux

| Linux | OpenBSD |
|---|---|
| `pactl` (PulseAudio) | `sndioctl` |
| `brightnessctl` | `xbacklight` |
| `xautolock` + `i3lock-fancy` | `xidle` (base) + `i3lock` |
| `bumblebee-status` | `i3status` (bateria pelo `apm`, volume pelo sndio) |
| `nm-applet`, `gnome-keyring`, `dex`, `xsettingsd` | removidos |
| `killall` | `pkill` |
| áreas `1` a `10` | `1:I` a `10:X`; a barra mostra só o romano (`strip_workspace_numbers yes`) |

Prints vão para `~/Imagens/Printscreens` (crie a pasta).
