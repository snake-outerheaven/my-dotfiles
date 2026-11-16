# openbsd-cwm

Desktop do OpenBSD com o **cwm flutuante**, Gruvbox dark com destaque amarelo.
Xenocara primeiro: `cwm`, `xterm`, `xidle` e `xlock` vêm na base; os pacotes
são só os que a base não oferece (barra, notificações, wallpaper, área de
transferência).

Sem compositor e sem tiling: as janelas flutuam, como o cwm foi pensado.

## Instalar

```sh
git clone -b openbsd-cwm https://github.com/snake-outerheaven/my-dotfiles ~/my-dotfiles
sh ~/my-dotfiles/scripts/install.sh -n   # simula
sh ~/my-dotfiles/scripts/install.sh      # instala (pacotes + stow)
startx                                   # ou entre pelo xenodm
```

Depois de editar o `.cwmrc`: `cwm -n -c ~/.cwmrc` testa, `Super+Shift+r` recarrega.

## Peças

| Peça | Programa | Origem |
|---|---|---|
| Gerenciador de janelas | `cwm` (`cwm/.cwmrc`) | base |
| Terminal | `xterm` (`x11/.Xresources`) | base |
| Lançador | `menu-exec` e `menu-cmd` do cwm | base |
| Bloqueio | `xidle` + `xlock` | base |
| Barra | `barra` (lemonbar-xft) | pacote |
| Notificações | `dunst` | pacote |
| Área de transferência | `copyq` | pacote |
| Wallpaper | `feh` (ou `xsetroot`) | pacote |
| Editor | `vim` sem plugins, tema `retrobox` | pacote |
| Arquivos, música, PDF, vídeo | `nnn`, `cmus`, `zathura`, `mpv` | pacotes |

## Atalhos (Super = tecla Windows)

| Atalho | Ação |
|---|---|
| `Super+Enter` | Terminal |
| `Super+d` | Executar programa (`menu-exec`) |
| `Super+/` | Menu de programas (`command` no `.cwmrc`) |
| `Super+w` / `Super+Shift+w` | Buscar janela / janelas escondidas |
| `Super+s` | SSH para um host do `known_hosts` |
| `Super+v` | Histórico do CopyQ |
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
| `Super+Shift+x` | Bloquear |
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

`cwm(1)`, `cwmrc(5)`, `xterm(1)`, `xidle(1)`, `xlock(1)`, `xenodm(1)`, `stow(8)`.
