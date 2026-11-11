# i3 no OpenBSD (branch `openbsd`)

Port da config do i3 para o OpenBSD, com as áreas em algarismos romanos (I a X).

## Pacotes

```sh
doas pkg_add i3 i3status i3lock alacritty rofi dunst picom feh scrot
```

`xidle`, `xbacklight` e `sndioctl` já vêm na base do OpenBSD.

## Arquivos

| No repositório | Vai para |
|---|---|
| `i3/config` | `~/.config/i3/config` |
| `i3status/config` | `~/.config/i3status/config` |

No `~/.xinitrc`: `exec i3`.

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
