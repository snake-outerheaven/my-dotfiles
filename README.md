# openbsd-cwm

Desktop do OpenBSD com o **cwm flutuante**, Tango com destaque amarelo (`#edd400` sobre `#2e3436`).
Sem barra, sem compositor, sem scripts.

**Regra:** tudo fica no `$HOME`, aplicado por você com `stow`, um pacote de cada vez.
Nada é instalado fora do `$HOME`, e nenhum script aplica nada por você.

## Pacotes do sistema (uma vez, com doas)

```sh
doas pkg_add stow rofi dunst libnotify copyq scrot i3lock feh noto-nerd-fonts
```

`cwm`, `xterm`, `xidle`, `xsetroot`, `xbacklight` e `sndioctl` já vêm na base.

## Aplicar

```sh
git clone -b openbsd-cwm https://github.com/snake-outerheaven/my-dotfiles ~/my-dotfiles
cd ~/my-dotfiles
stow -n -v cwm      # mostra o que faria
stow cwm            # aplica; repita para cada pacote que quiser
```

| Pacote | Vai para | Para quê |
|---|---|---|
| `cwm` | `~/.cwmrc` | Gerenciador de janelas: aparência, grupos, menus e **todos os atalhos** |
| `x11` | `~/.xinitrc`, `~/.xsession`, `~/.Xresources` | O que sobe com a sessão (D-Bus, dunst, copyq, xidle) e as cores do xterm |
| `dunst` | `~/.config/dunst/dunstrc` | Notificações |
| `rofi` | `~/.config/rofi/config.rasi` | Lançador (`Super+d`) |
| `copyq` | `~/.config/copyq/tango.ini` | Tema; aplicar uma vez com `copyq loadTheme ~/.config/copyq/tango.ini` |
| `tmux`, `cmus`, `mpv`, `zathura` | Cada um no seu lugar em `~/` ou `~/.config/` | Opcionais |

Se um arquivo seu já existir no lugar, o `stow` avisa e não mexe nele: mova o seu primeiro.
Desfazer um pacote: `stow -D cwm`.

Depois de editar o `~/.cwmrc`: `cwm -n -c ~/.cwmrc` testa, `Super+Shift+r` recarrega.

## Atalhos (Super = tecla Windows)

| Atalho | Ação |
|---|---|
| `Super+Enter` | Terminal |
| `Super+d` / `Super+Shift+d` | Lançador de apps / executar comando (`rofi`) |
| `Super+Tab` | Trocar de janela (`rofi`) |
| `Alt+Tab` / `Alt+Shift+Tab` | Alternar janelas do grupo |
| `Super+/` | Menu de programas |
| `Super+w` / `Super+Shift+w` | Buscar janela / janelas escondidas |
| `Super+s` | SSH para um host do `known_hosts` |
| `Super+v` | Histórico do CopyQ |
| `Super+i` | Hora, data, volume e bateria numa notificação |
| `Super+h/j/k/l` | Encaixar na borda |
| `Super+Shift+h/j/k/l` | Mover |
| `Super+Ctrl+h/j/k/l` | Redimensionar |
| `Super+c` / `Super+m` / `Super+Shift+m` / `Super+f` | Centralizar / maximizar / maximizar na vertical / tela cheia |
| `Super+-` / `Super+p` / `Super+n` | Esconder / fixar em todos os grupos / dar nome |
| `Super+Shift+q` | Fechar janela |
| `Super+1..9` / `Super+Shift+1..9` | Ir para o grupo / mandar janela |
| ``Super+` `` / `Super+←/→` | Grupo anterior / percorrer grupos |
| `Print` / `Super+Print` | Print da tela / de uma área (`scrot`, em `~/Downloads`) |
| Teclas de volume e brilho | `sndioctl` / `xbacklight` |
| `Super+Shift+x` / `Super+Shift+r` / `Super+Shift+e` | Bloquear / recarregar o cwm / sair |

| Mouse | Ação |
|---|---|
| `Super` + esquerdo / direito / meio | Mover / redimensionar / mandar para trás |
| No fundo: esquerdo / meio / direito | Menu de janelas / programas / grupos |
