" ~/.vimrc - Vim sem plugins, cores Tango com destaque amarelo
" Tudo daqui está no :help. Recarregar: :source ~/.vimrc

" ------------------------------------------------------------ básico
set nocompatible
filetype plugin indent on
syntax on
set encoding=utf-8
set hidden                      " troca de buffer sem salvar
set mouse=a                     " mouse no xterm
set backspace=indent,eol,start
set history=1000
set scrolloff=4
set splitbelow splitright       " :split embaixo, :vsplit à direita
set wildmenu wildmode=longest:full,full
set path+=**                    " :find busca nos subdiretórios

" ------------------------------------------------------------ cores (Tango)
" sem colorscheme: o Vim usa as 16 cores do terminal, que o ~/.Xresources
" deixa em Tango. Aqui só o destaque amarelo (3 = #c4a000, 11 = #fce94f).
set background=dark
hi LineNr       ctermfg=8
hi CursorLineNr ctermfg=11 cterm=bold
hi CursorLine   cterm=NONE ctermbg=NONE
hi Search       ctermfg=0  ctermbg=3
hi IncSearch    ctermfg=0  ctermbg=11 cterm=NONE
hi Visual       ctermfg=NONE ctermbg=8
hi StatusLine   ctermfg=0  ctermbg=11 cterm=bold
hi StatusLineNC ctermfg=7  ctermbg=8  cterm=NONE
hi VertSplit    ctermfg=8  ctermbg=NONE cterm=NONE
hi ColorColumn  ctermbg=0
hi NonText      ctermfg=8
hi SpecialKey   ctermfg=8

" ------------------------------------------------------------ tela
set number relativenumber
set cursorline
set showcmd
set laststatus=2
set noshowmode                  " o modo aparece na barra de status
set list listchars=tab:»\ ,trail:·,nbsp:␣
set colorcolumn=80

" barra de status sem plugin: modo | arquivo [+] | tipo | linha:coluna
function! Modo() abort
  return get({'n':'NORMAL','i':'INSERT','v':'VISUAL','V':'V-LINE',"\<C-v>":'V-BLOCO',
        \ 'R':'REPLACE','c':'COMANDO','t':'TERMINAL'}, mode(), mode())
endfunction
set statusline=\ %{Modo()}\ \|\ %f%m%r%=%y\ \|\ %l:%c\ \|\ %p%%

" ------------------------------------------------------------ busca
set incsearch hlsearch
set ignorecase smartcase

" ------------------------------------------------------------ indentação
" padrão: estilo OpenBSD, style(9) - tab de 8
set tabstop=8 shiftwidth=8 noexpandtab
set autoindent
augroup indentacao
  autocmd!
  autocmd FileType c,cpp,make,sh setlocal tabstop=8 shiftwidth=8 noexpandtab cinoptions=:0,t0,+4,(4
  autocmd FileType python,yaml,markdown,html,css,javascript,vim
        \ setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
  autocmd FileType markdown,text setlocal textwidth=72 spell spelllang=pt_br,en
augroup END

" ------------------------------------------------------------ arquivos
set undofile undodir=~/.vim/undo//      " desfazer sobrevive ao fechar
set noswapfile
set nobackup nowritebackup
silent! call mkdir(expand('~/.vim/undo'), 'p', 0700)

" netrw (explorador embutido: :Ex ou <espaço>e)
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = 25

" ------------------------------------------------------------ atalhos
let mapleader = " "
nnoremap <leader>w :write<CR>
nnoremap <leader>q :quit<CR>
nnoremap <leader>e :Lexplore<CR>
nnoremap <leader>f :find<space>
nnoremap <leader>b :ls<CR>:buffer<space>
nnoremap <leader>h :nohlsearch<CR>
nnoremap <leader>s :setlocal spell!<CR>
" janelas com Ctrl+h/j/k/l
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
" copiar e colar pelo CopyQ (o servidor sobe com a sessão do cwm)
" espaço y: seleção vai para a área de transferência e para o histórico do CopyQ
" espaço p: cola o item atual; espaço v: abre o histórico (Super+v também abre)
vnoremap <leader>y :w !copyq copy - >/dev/null<CR><CR>
nnoremap <leader>p :read !copyq clipboard<CR>
nnoremap <leader>v :silent !copyq toggle<CR>:redraw!<CR>

" volta ao último ponto do arquivo ao reabrir
augroup ultimo_ponto
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END
