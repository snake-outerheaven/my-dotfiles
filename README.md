# openbsd-cwm

Desktop do OpenBSD com o **cwm flutuante**, Tango com destaque amarelo (`#edd400`).
Xenocara primeiro: `cwm`, `xterm` e `xidle` vêm na base; os pacotes cobrem o
que a base não oferece (lançador, bloqueio, notificações, wallpaper, área de
transferência).

Sem barra, sem compositor e sem tiling: `Super+i` mostra hora, grupo, bateria e
volume numa notificação, e as janelas flutuam, como o cwm foi pensado.

## Instalar

```sh
git clone -b openbsd-cwm https://github.com/snake-outerheaven/my-dotfiles ~/my-dotfiles
sh ~/my-dotfiles/scripts/install.sh -n   # simula
sh ~/my-dotfiles/scripts/install.sh      # instala (pacotes + stow)
startx                                   # ou entre pelo xenodm
```

O `install.sh` monta o desktop inteiro, em etapas:

| Etapa | O que faz |
|---|---|
| Pacotes e programas | Instala o que falta (pula o que já existe) |
| Fontes, lazer e jogos | Opcionais: seguem mesmo se algum falhar |
| Sistema | Pergunta antes: `xenodm` no boot, `apmd -A`, classe `staff` para o usuário |
| Tema do CopyQ | Tango amarelo |
| Dotfiles | `stow` de cada pacote, com backup do que atrapalhar |
| Pastas | Cria as pastas do `xdg-user-dirs` (abaixo) |

Pastas do usuário (`xdg/.config/user-dirs.dirs`), em português, sem acento:
`Desktop`, `Documentos`, `Downloads`, `Musica`, `Imagens`, `Videos`, `Modelos`, `Publico`.
O `printar` salva em `Imagens/Capturas`.

Depois de editar o `.cwmrc`: `cwm -n -c ~/.cwmrc` testa, `Super+Shift+r` recarrega.

## Peças

| Peça | Programa | Origem |
|---|---|---|
| Gerenciador de janelas | `cwm` (`cwm/.cwmrc`) | base |
| Terminal | `xterm` (`x11/.Xresources`) | base |
| Lançador | `rofi` (apps, comandos e janelas, com busca) | pacote |
| Menus extras | `menu-cmd`, `menu-window`, `menu-ssh` do cwm | base |
| Bloqueio | `i3lock` (Tango), chamado pelo `xidle` após 5 min | pacote + base |
| Notificações | `dunst` | pacote |
| Área de transferência | `copyq` | pacote |
| Wallpaper | `feh` com as flores amarelas (`pega-wallpaper`), ou cor lisa pelo `xsetroot` | pacote / base |
| Editor | `vim` sem plugins, cores Tango pelas 16 cores do terminal | pacote |
| Arquivos, música, PDF, vídeo | `ranger`, `cmus`, `zathura`, `mpv` | pacotes |
| Navegador, monitor | `firefox`, `htop` | pacotes |
| Fonte | Noto Nerd Font (`NotoSansM Nerd Font Mono`) | pacote |
| Lazer | `supertux`, `supertuxkart`, `openttd` e os brinquedos do `lazer` | pacotes |

## Atalhos (Super = tecla Windows)

| Atalho | Ação |
|---|---|
| `Super+Enter` | Terminal |
| `Super+d` | Lançador de apps (`rofi -show drun`) |
| `Super+Shift+d` | Executar qualquer comando (`rofi -show run`) |
| `Super+Tab` | Trocar de janela (`rofi -show window`) |
| `Alt+Tab` | Alternar janelas do grupo |
| `Super+/` | Menu de programas (`command` no `.cwmrc`) |
| `Super+w` / `Super+Shift+w` | Buscar janela / janelas escondidas |
| `Super+s` | SSH para um host do `known_hosts` |
| `Super+v` | Histórico do CopyQ |
| `Super+i` | Hora, grupo, bateria e volume (notificação) |
| `Super+h/j/k/l` | Encaixar na borda |
| `Super+Shift+h/j/k/l` | Mover pelo teclado |
| `Super+Ctrl+h/j/k/l` | Redimensionar pelo teclado |
| `Super+c` / `Super+m` / `Super+f` | Centralizar / maximizar / tela cheia |
| `Super+-` | Esconder janela |
| `Super+p` | Fixar em todos os grupos |
| `Super+n` | Dar nome à janela |
| `Super+1..9` / `Super+Shift+1..9` | Ir para o grupo / mandar janela |
| ``Super+` `` / `Super+←/→` | Grupo anterior / percorrer grupos |
| `Super+Shift+q` | Fechar janela |
| `Super+Shift+x` | Bloquear (`i3lock`) |
| `Super+Shift+r` / `Super+Shift+e` | Recarregar / sair |
| `Super` + arrastar | Mover (botão esquerdo) / redimensionar (direito) |
| Clique no fundo | Esquerdo: janelas · meio: programas · direito: grupos |

## Vim (líder = espaço)

| Atalho | Ação |
|---|---|
| `espaço w` / `espaço q` | Salvar / sair |
| `espaço e` | Explorador (netrw) |
| `espaço f` / `espaço b` | `:find` / buffers |
| `espaço y` / `espaço p` / `espaço v` | Copiar / colar / histórico (CopyQ) |
| `espaço h` / `espaço s` | Limpar busca / corretor |

C, sh e Makefile seguem o `style(9)` (tab de 8).

## Referências

`cwm(1)`, `cwmrc(5)`, `xterm(1)`, `xidle(1)`, `rofi(1)`, `i3lock(1)`, `xenodm(1)`, `stow(8)`.
