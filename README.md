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

O `install-debian.sh` baixa o wallpaper do **Initial D** (AE86) da coleção [AngelJumbo/gruvbox-wallpapers](https://github.com/AngelJumbo/gruvbox-wallpapers) para `~/Imagens/wallpapers/wall.png`. Para trocar, substitua esse arquivo (ou use `wall.jpg`) e rode `swaymsg reload`. Sem imagem, o fundo fica na cor sólida `#282828`.

### Trocar de wallpaper

```sh
~/.config/sway/scripts/wall.sh                        # lista as imagens e mostra a atual
~/.config/sway/scripts/wall.sh /caminho/imagem.jpg    # preenche a tela
~/.config/sway/scripts/wall.sh /caminho/imagem.jpg fit   # quadro inteiro, faixas #282828
```

A escolha fica salva em `~/.config/sway/wallpaper.atual` e volta sozinha no próximo login.

### Quadros do Courbet

`sh wallpapers/courbet.sh` (o install já roda) baixa 9 quadros do Gustave Courbet, em domínio público, do Wikimedia Commons para `~/Imagens/wallpapers/courbet/`: naturezas-mortas de 1871–72, riachos e florestas, e *A Onda*. Para as naturezas-mortas, que são quase quadradas, use o modo `fit`.

## Pacotes do stow

| Pasta | Vai para |
|---|---|
| `sway` | `~/.config/sway/config` e `scripts/` (`print.sh`, `clipboard.sh`, `wallpaper.sh`, `wall.sh`, `status.sh`) |
| `swaylock` | `~/.config/swaylock/config` |
| `fuzzel` | `~/.config/fuzzel/fuzzel.ini` |
| `alacritty` | `~/.config/alacritty/alacritty.toml` |
| `dunst` | `~/.config/dunst/dunstrc` |
| `tmux` | `~/.tmux.conf` |
| `ranger` | `~/.config/ranger/rc.conf` (preview, bordas) |
| `btop` | `~/.config/btop/btop.conf` (tema `gruvbox_dark`) |
| `cava` | `~/.config/cava/config` (gradiente Gruvbox) |
| `autostart` | `~/.config/autostart/nm-applet.desktop` (bandeja no swaybar) |

## Utilidades instaladas

| Para quê | Programa |
|---|---|
| Áudio | PipeWire (`pipewire-pulse`, `wireplumber`), `pavucontrol`, `pulsemixer`, `playerctl` |
| Arquivos | `ranger` (com `highlight` e `atool` nas prévias) |
| Sistema | `fastfetch`, `btop` |
| Ricing | `cava` (visualizador de áudio), `cmatrix`, `tty-clock`, ícones `Papirus-Dark` |
| Mídia | `imv` (imagens), `mpv` (vídeo), `zathura` (PDF) |
| Terminal | `bat`, `ripgrep`, `fd-find`, `fzf` |

## Atalhos (`Super`)

| Atalho | Faz |
|---|---|
| `Super+Enter` | terminal (alacritty) |
| `Super+D` | lançador (fuzzel) |
| `Super+N` | arquivos (ranger) |
| `Super+Shift+B` | monitor do sistema (btop) |
| `Super+Shift+A` | mixer de áudio (pavucontrol) |
| Teclas de volume / mídia | volume, mudo, microfone, play/pause, próxima, anterior |
| Mouse na barra | roda = volume, botão do meio = mudo, botão direito = mixer |
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
| `i3bar` + bumblebee-status | `swaybar` com `scripts/status.sh`: volume, bateria (ou `AC` no desktop) e data, em cores Gruvbox |

Correções aproveitadas no caminho: `bindsym $mod + r` (com espaços) virou `$mod+r`; o print de área salvava em `~/Pictures` e o de tela em `~/Imagens` (agora os dois vão para `~/Imagens/Printscreens`); o componente `pkcs` do gnome-keyring virou `pkcs11`; o `timeout = 0# vim` do dunst foi separado.

## Licença

GPL-3.0, igual ao original.
