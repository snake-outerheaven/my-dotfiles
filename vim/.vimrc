" ~/.vimrc - simples, em Tango (sem plugin)
set nocompatible
syntax on
filetype plugin indent on
set background=dark
" cores Tango em ~/.vim/cores.vim; ajustes desta maquina em ~/.vim/local.vim (pode nao existir)
source ~/.vim/cores.vim
set number
set ruler
set incsearch hlsearch
set tabstop=8 shiftwidth=8 noexpandtab   " estilo OpenBSD (style(9))
silent! source ~/.vim/local.vim
