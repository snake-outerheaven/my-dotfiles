# bsd-i3: i3 amarelo Tango no OpenBSD

Branch `bsd-i3` do `my-dotfiles`. Desktop com i3, barra i3status, rofi, alacritty, dunst e copyq, na paleta Tango com destaque amarelo (`#edd400` sobre `#2e3436`). **Só OpenBSD.**

**Regra:** o setup não mexe no seu espaço. Scripts e configurações ficam no sistema; no `$HOME` entram só o `~/.xinitrc` e o `~/.xsession`. Nenhum arquivo seu é apagado: do `$HOME` saem só os links que versões antigas desta branch criaram (e as pastas que eles deixarem vazias).

## Instalar

Pré-requisitos: `doas` configurado, `/etc/installurl` válido e `git`.

```sh
doas pkg_add git
git clone -b bsd-i3 https://github.com/snake-outerheaven/my-dotfiles ~/bsd-i3
cd ~/bsd-i3
sh install.sh -n     # simula
sh install.sh        # instala
startx
```

| Etapa | O que faz |
|---|---|
| 1. Conferências | OpenBSD, `doas` e a árvore do repositório |
| 2. Pacotes | Essenciais `i3 i3status i3lock stow rofi alacritty` (falha **para** o script); opcionais `dunst libnotify copyq feh scrot xdg-user-dirs dbus cascadia-code noto-emoji firefox` (falha vira aviso) e os grupos abaixo |
| 3. Sistema | `scripts/` → `/usr/local/libexec/bsd-i3/` (755); `share/` → `/usr/local/share/bsd-i3/` (644) |
| 4. Perfil | Detecta `notebook` ou `desktop` e grava `/etc/bsd-i3/perfil` |
| 5. Limpeza | Remove do `$HOME` só os **links** que qualquer versão antiga desta branch criou (destino em `<repo>/<pacote>/<mesmo caminho>`); arquivos e links seus ficam |
| 6. `$HOME` | `stow --no-folding x11`: `~/.xinitrc` e `~/.xsession`. O que atrapalhar (arquivo ou link de fora) vai para `~/.dotfiles-backup-DATA`; se o stow ainda vir conflito, o script **para** e diz onde está o backup |
| 7. Resumo | Opcionais que falharam; avisa se faltar o `i3lock` ou a fonte |

Grupos extras (todos por padrão; escolha com `GRUPOS`, por exemplo `GRUPOS="apps jogos" sh install.sh`):

| Grupo | Pacotes |
|---|---|
| `apps` | `nnn zathura zathura-pdf-mupdf mpv cmus vim--no_x11` |
| `jogos` | `supertux supertuxkart openttd` |
| `lazer` | `cmatrix tty-clock cowsay figlet sl asciiquarium` |
| `fontes` | `noto-cjk` |

## Onde fica cada coisa

| No repositório | Instalado em | Conteúdo |
|---|---|---|
| `scripts/` | `/usr/local/libexec/bsd-i3/` | `barra`, `volume`, `printar`, `bloqueio`, `fundo`, `perfil-maquina` |
| `share/` | `/usr/local/share/bsd-i3/` | `i3.conf`, `i3status-notebook.conf`, `i3status-desktop.conf`, `alacritty.toml`, `rofi.rasi`, `dunstrc`, `copyq-tango.ini`, `Xresources` |
| — | `/etc/bsd-i3/perfil` | `desktop` ou `notebook` |
| `x11/` | `~/.xinitrc`, `~/.xsession` (links) | D-Bus, `xrdb`, `exec i3 -c /usr/local/share/bsd-i3/i3.conf` |
| `sistema/openbsd/` | `/etc/apm/suspend` (à mão) | Bloqueia a tela antes de suspender |
| `extras/` | nada, por padrão | Configs pessoais opcionais (abaixo) |

Cada programa recebe o arquivo do sistema pelo caminho completo: `alacritty --config-file`, `rofi -config`, `dunst -config`, `copyq loadTheme`, `i3status -c`.

Seus arquivos têm prioridade quando fazem sentido: um `~/.Xresources` entra por cima das cores do bsd-i3, e um `~/.fehbg` substitui o fundo liso.

## Notebook ou desktop

| Perfil | Barra |
|---|---|
| `notebook` | `VOL` · `BAT` · data e hora |
| `desktop` | `VOL` · data e hora (sem bateria: nada de alerta falso) |

O `perfil-maquina` decide nesta ordem: variável `PERFIL` → `/etc/bsd-i3/perfil` → hardware (sensor `acpibat*`, ou `apm` com carga de 1 a 100). Forçar: `PERFIL=desktop sh install.sh`.

O volume vai para a barra por um arquivo em `/tmp/bsd-i3-UID/` (pasta modo 700, só sua): o i3status não lê o `sndiod`, então o script `volume` grava o valor e manda `SIGUSR1` ao seu i3status.

## Atalhos (Mod = `Super`)

| Atalho | Ação |
|---|---|
| `Super+Enter` | Terminal (alacritty) |
| `Super+d` | rofi (programas) |
| `Super+Shift+q` | Fecha a janela |
| `Super+j/k/l/;` ou setas | Foco |
| `Super+Shift+j/k/l/;` ou setas | Move a janela |
| `Super+h` / `Super+v` | Próxima janela ao lado / embaixo |
| `Super+f` | Tela cheia |
| `Super+s` / `Super+w` / `Super+e` | Empilhado / abas / alterna divisão |
| `Super+Shift+Espaço` / `Super+Espaço` | Flutuante / foco entre flutuante e lado a lado |
| `Super+a` | Foco no pai |
| `Super+Shift+-` / `Super+-` | Manda para o scratchpad / mostra o scratchpad |
| `Super+1..0` / `Super+Shift+1..0` | Vai para a área I a X / manda a janela |
| `Super+r` | Modo de redimensionar (`Esc` sai) |
| `Super+Shift+c` / `Super+Shift+r` / `Super+Shift+e` | Recarrega / reinicia / sai do i3 |
| `Print` / `Super+Print` | Print da tela / de uma área em `~/Downloads` |
| `Super+Shift+x` | Bloqueia a tela (i3lock) |
| Teclas de volume / brilho | `volume` (`sndioctl`) / `xbacklight` |

A tela também bloqueia após 5 minutos parado (`xidle` → `bloqueio`).

## Bloquear ao suspender (opcional)

```sh
doas install -o root -g wheel -m 755 sistema/openbsd/etc/apm/suspend /etc/apm/suspend
doas ln -sf suspend /etc/apm/hibernate
doas rcctl enable apmd && doas rcctl start apmd
```

## Extras: configs pessoais (opcional)

`extras/` guarda configs de `vim`, `tmux`, `cmus`, `mpv` e `zathura`. O `install.sh` **não** aplica nenhuma. Para usar uma, escolha você:

```sh
cd ~/bsd-i3
stow -d extras -t ~ vim          # ~/.vimrc
stow -d extras -t ~ --no-folding tmux zathura
stow -d extras -t ~ -D vim       # desfaz
```

## Atualizar ou mudar algo

Edite o arquivo em `share/` ou `scripts/` e rode de novo:

```sh
cd ~/bsd-i3 && git pull && sh install.sh
```

Depois, `Super+Shift+r` recarrega o i3 (e a barra). Mudanças no `.xinitrc` valem no próximo `startx`.
