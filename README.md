# openbsd-cwm

Desktop do OpenBSD com o **cwm flutuante**, Tango com destaque amarelo (`#edd400` sobre `#2e3436`).
Xenocara primeiro: `cwm`, `xterm` e `xidle` vêm na base; os pacotes cobrem o resto
(lançador, bloqueio, notificações, área de transferência).

Sem barra, sem compositor e sem tiling: `Super+i` mostra hora, grupo, bateria e volume
numa notificação.

**Regra:** o setup não mexe no seu `~/bin`. Scripts e arquivos do projeto ficam no sistema;
no `$HOME` entram só `~/.xinitrc`, `~/.xsession`, `~/.cwmrc` e `~/.Xresources` (os dois
últimos são seus para editar).

## Instalar

```sh
doas pkg_add git
git clone -b openbsd-cwm https://github.com/snake-outerheaven/my-dotfiles ~/my-dotfiles
cd ~/my-dotfiles
sh install.sh -n     # simula
sh install.sh        # instala
startx               # ou entre pelo xenodm
```

| Etapa | O que faz |
|---|---|
| 1. Conferências | OpenBSD, `doas` e a árvore do repositório |
| 2. Pacotes | Essenciais `rofi i3lock dunst stow` (falha **para** o script); opcionais `libnotify copyq feh scrot xdg-user-dirs dbus noto-nerd-fonts git firefox` (falha vira aviso) e os grupos abaixo |
| 3. Sistema | `scripts/` → `/usr/local/libexec/openbsd-cwm/` (755); `share/` → `/usr/local/share/openbsd-cwm/` (644) |
| 4. Perfil | Detecta `notebook` ou `desktop` e grava `/etc/openbsd-cwm/perfil` |
| 5. Links antigos | Links de versões antigas que apontam para arquivos movidos: os de `extras/` são refeitos (sua config continua valendo); os que foram para o sistema saem |
| 6. `$HOME` | `stow --no-folding x11 cwm`. O que atrapalhar vai para `~/.dotfiles-backup-DATA`; se o stow ainda vir conflito, o script **para** |
| 7. Resumo | Opcionais que falharam; avisa se faltar o `i3lock` ou a fonte |

Grupos extras (todos por padrão; escolha com `GRUPOS`, por exemplo `GRUPOS="apps" sh install.sh`):

| Grupo | Pacotes |
|---|---|
| `apps` | `ranger htop zathura zathura-pdf-mupdf mpv cmus vim--no_x11` |
| `jogos` | `supertux supertuxkart openttd` |
| `lazer` | `cmatrix tty-clock cowsay figlet sl asciiquarium` |
| `fontes` | `noto-emoji noto-cjk` |

## Onde fica cada coisa

| Repositório | Instalado em | Conteúdo |
|---|---|---|
| `scripts/` | `/usr/local/libexec/openbsd-cwm/` | `cwm-session`, `fundo`, `infos`, `midia`, `printar`, `lazer`, `perfil-maquina` |
| `share/` | `/usr/local/share/openbsd-cwm/` | `dunstrc`, `rofi.rasi`, `copyq-tango.ini` |
| — | `/etc/openbsd-cwm/perfil` | `desktop` ou `notebook` |
| `x11/` | `~/` (stow) | `.xinitrc`, `.xsession`, `.Xresources` |
| `cwm/` | `~/` (stow) | `.cwmrc` |
| `extras/` | só se você quiser | `vim`, `tmux`, `cmus`, `mpv`, `zathura`, `xdg` |
| `sistema/openbsd/` | à mão, como root | `etc/apm/suspend` |

Configs opcionais: `stow --no-folding -d ~/my-dotfiles/extras -t ~ vim` (ou `tmux`, `cmus`...).

Depois de editar o `~/.cwmrc`: `cwm -n -c ~/.cwmrc` testa, `Super+Shift+r` recarrega.
Mudou algo em `scripts/` ou `share/`: rode `sh install.sh` de novo.

## Perfil: notebook ou desktop

| Perfil | `Super+i` |
|---|---|
| `notebook` | hora, grupo, bateria, volume |
| `desktop` | hora, grupo, volume (sem `BAT 0%` falso) |

Ordem de decisão do `perfil-maquina`: variável `PERFIL` → `/etc/openbsd-cwm/perfil` →
hardware (sensor `acpibat*`, ou `apm` com carga de 1 a 100).
Forçar: `PERFIL=desktop sh install.sh`.

## Fora do escopo (faça à mão, como root)

| Ajuste | Comando |
|---|---|
| Login gráfico no boot | `rcctl enable xenodm` |
| CPU conforme a carga | `rcctl enable apmd && rcctl set apmd flags -A && rcctl start apmd` |
| Mais memória para o Firefox | Classe `staff` (`usermod -L staff <usuario>`) e o `datasize` dela no `/etc/login.conf`, depois `cap_mkdb /etc/login.conf` |
| Bloquear antes de suspender | `install -o root -g wheel -m 755 sistema/openbsd/etc/apm/suspend /etc/apm/suspend` |

## Peças

| Peça | Programa | Origem |
|---|---|---|
| Gerenciador de janelas | `cwm` (`~/.cwmrc`) | base |
| Terminal | `xterm` (`~/.Xresources`) | base |
| Lançador | `rofi -config /usr/local/share/openbsd-cwm/rofi.rasi` | pacote |
| Menus extras | `menu-cmd`, `menu-window`, `menu-ssh` do cwm | base |
| Bloqueio | `i3lock`, chamado pelo `xidle` após 5 min | pacote + base |
| Notificações | `dunst -config /usr/local/share/openbsd-cwm/dunstrc` | pacote |
| Área de transferência | `copyq`, tema Tango | pacote |
| Fundo | o seu `~/.fehbg`, ou a cor lisa Tango | base |
| Volume e brilho | `midia`: `sndioctl` / `xbacklight`, com o valor no dunst | base + pacote |
| Print | `printar` (`scrot`) em `~/Downloads` | pacote |
| Fonte | Noto Nerd Font (`NotoSansM Nerd Font Mono`) | pacote |

## Atalhos (Super = tecla Windows)

| Atalho | Ação |
|---|---|
| `Super+Enter` | Terminal |
| `Super+d` / `Super+Shift+d` | Lançador de apps / executar comando (`rofi`) |
| `Super+Tab` | Trocar de janela (`rofi`) |
| `Alt+Tab` / `Alt+Shift+Tab` | Alternar janelas do grupo |
| `Super+/` | Menu de programas (`command` no `.cwmrc`) |
| `Super+w` / `Super+Shift+w` | Buscar janela / janelas escondidas |
| `Super+s` | SSH para um host do `known_hosts` |
| `Super+v` | Histórico do CopyQ |
| `Super+i` | Hora, grupo, bateria e volume |
| `Super+h/j/k/l` | Encaixar na borda |
| `Super+Shift+h/j/k/l` | Mover |
| `Super+Ctrl+h/j/k/l` | Redimensionar |
| `Super+c` / `Super+m` / `Super+Shift+m` / `Super+f` | Centralizar / maximizar / maximizar na vertical / tela cheia |
| `Super+-` / `Super+p` / `Super+n` | Esconder / fixar em todos os grupos / dar nome |
| `Super+Shift+q` | Fechar janela |
| `Super+1..9` / `Super+Shift+1..9` | Ir para o grupo / mandar janela |
| ``Super+` `` / `Super+←/→` | Grupo anterior / percorrer grupos |
| `Print` / `Super+Print` | Print da tela / de uma área |
| Teclas de volume e brilho | `midia`, com o valor no dunst |
| `Super+Shift+x` / `Super+Shift+r` / `Super+Shift+e` | Bloquear / recarregar o cwm / sair |

| Mouse | Ação |
|---|---|
| `Super` + esquerdo / direito / meio | Mover / redimensionar / mandar para trás |
| No fundo: esquerdo / meio / direito | Menu de janelas / programas / grupos |
