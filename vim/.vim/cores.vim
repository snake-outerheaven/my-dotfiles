" cores.vim - Tango (referencia: paleta/tango.txt)
" sem colorscheme: o padrao do Vim usa as 16 cores ANSI do terminal (Tango no alacritty)
hi LineNr       ctermfg=8                     guifg=#555753
hi CursorLineNr ctermfg=3  cterm=bold         guifg=#edd400 gui=bold
hi Search       ctermfg=0  ctermbg=3          guifg=#2e3436 guibg=#edd400
hi IncSearch    ctermfg=0  ctermbg=11 cterm=NONE guifg=#2e3436 guibg=#fce94f gui=NONE
hi Visual       ctermfg=NONE ctermbg=8        guifg=NONE    guibg=#555753
hi StatusLine   ctermfg=0  ctermbg=3  cterm=bold guifg=#2e3436 guibg=#edd400 gui=bold
hi StatusLineNC ctermfg=7  ctermbg=8  cterm=NONE guifg=#d3d7cf guibg=#555753 gui=NONE
hi VertSplit    ctermfg=8  ctermbg=NONE cterm=NONE guifg=#555753 guibg=NONE gui=NONE
