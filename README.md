# my-dotfiles: branch `sway`

Port do meu rice de i3 (branch [`master`](https://github.com/snake-outerheaven/my-dotfiles/tree/master)) para o **Sway** (Wayland), com a paleta **Gruvbox**.
Feito para o **Debian 13** e organizado para o [GNU stow](https://www.gnu.org/software/stow/).

## Instalar

```sh
git clone -b sway https://github.com/snake-outerheaven/my-dotfiles ~/my-dotfiles
cd ~/my-dotfiles && sh install-debian.sh
```

Depois, escolha **Sway** na tela de login (ou rode `sway` num TTY).

## Wallpaper

Coloque a imagem em `~/Imagens/wallpapers/wall.jpg` e rode `swaymsg reload`. Sem ela, o fundo fica na cor sólida `#282828`.

## Pacotes do stow

| Pasta | Vai para |
|---|---|
| `sway` | `~/.config/sway/config` e `scripts/` (`print.sh`, `clipboard.sh`) |
| `swaylock` | `~/.config/swaylock/config` |
| `fuzzel` | `~/.config/fuzzel/fuzzel.ini` |
| `alacritty` | `~/.config/alacritty/alacritty.toml` |
| `dunst` | `~/.config/dunst/dunstrc` |
| `tmux` | `~/.tmux.conf` |
| `autostart` | `~/.config/autostart/nm-applet.desktop` (bandeja no swaybar) |

## Atalhos (`Super`)

| Atalho | Faz |
|---|---|
| `Super+Enter` | terminal (alacritty) |
| `Super+D` | lançador (fuzzel) |
| `Super+Shift+Q` | fecha a janela |
| `Super+H/J/K/L` ou setas | foco |
| `Super+Shift+H/J/K/L` | move a janela |
| `Super+F` | tela cheia |
| `Super+S` / `W` / `E` | empilhado / abas / alternar divisão |
| `Super+Shift+Espaço` | flutuante |
| `Super+Espaço` | alterna foco tiling / flutuante |
| `Super+A` | foca o container pai |
| `Super+R` | modo redimensionar |
| `Super+1..0` | workspaces I a X (números romanos) |
| `Super+Shift+1..0` | move a janela para o workspace |
| `Super+Shift+X` | bloqueia a tela |
| `Print` / `Super+Print` | print da tela / de uma área |
| `Super+V` | histórico do clipboard (cliphist + fuzzel) |
| `Super+Shift+V` | apaga o histórico do clipboard |
| `Super+Shift+C` | recarrega a config |
| `Super+Shift+E` | sai do Sway |

## O que mudou do i3 (X11) para o Sway (Wayland)

| i3 | Sway |
|---|---|
| paleta Everforest | **Gruvbox** (escuro) |
| `feh` (wallpaper) | `output * bg` (swaybg) |
| `picom` (sombra, fade, blur) | não tem no Sway puro |
| `xautolock` + `i3lock-fancy` | `swayidle` + `swaylock` |
| `scrot` | `grim` + `slurp` (`scripts/print.sh`) |
| `rofi` | `fuzzel` |
| `i3-nagbar` / `i3-msg` | `swaynag` / `swaymsg` |
| `restart` | não existe: só `reload` |
| `xsettingsd` | `gsettings` |
| layout do teclado no X | bloco `input` (br abnt2) |
| `i3bar` + bumblebee-status | `swaybar` com status simples (data e hora) |

Correções aproveitadas no caminho: `bindsym $mod + r` (com espaços) virou `$mod+r`; o print de área salvava em `~/Pictures` e o de tela em `~/Imagens` (agora os dois vão para `~/Imagens/Printscreens`); o componente `pkcs` do gnome-keyring virou `pkcs11`; o `timeout = 0# vim` do dunst foi separado.

## Licença

GPL-3.0, igual ao original.
