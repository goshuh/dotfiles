" mappings {{{
let mapleader=';'

noremap  <silent> *                  :vim /\<<c-r><c-w>\>/gj %<cr> :cw<cr>*
noremap  <silent> <f2>               :cw<cr>
noremap  <silent> <f3>               :cp<cr>
noremap  <silent> <f4>               :cn<cr>
noremap  <silent> <f5>               :up<cr>
noremap  <silent> <f6>               :source ~/.vimrc<cr>
noremap  <silent> <f12>              :cal 
noremap  <silent> <c-up>              ddkP
noremap  <silent> <c-down>            ddp
noremap  <silent> <c-left>           :bp<cr>
noremap  <silent> <c-right>          :bn<cr>
noremap  <silent> <c-pageup>         :tabp<cr>
noremap  <silent> <c-pagedown>       :tabn<cr>
noremap  <silent> <s-up>              v<up>
noremap  <silent> <s-down>            v<down>
noremap  <silent> <s-left>            v<left>
noremap  <silent> <s-right>           v<right>
noremap  <silent> <space>             i
noremap           <leader><cr>       :e 
noremap           <leader>-          :new 
noremap           <leader>\          :vne 
noremap           <leader>=          :vert diffsplit 
noremap  <silent> <leader>t          :tabe 
noremap  <silent> <leader>w          :bw<cr>
noremap  <silent> <leader>q          :q<cr>
noremap  <silent> <leader>c          :sp<cr>
noremap  <silent> <leader>v          :vs<cr>
noremap  <silent> <leader>f          :vert wincmd f<cr>
noremap  <silent> <leader>d           <c-w>f
noremap  <silent> <leader>1           <c-w>H
noremap  <silent> <leader>2           <c-w>K
noremap  <silent> <leader>3           <c-w>J
noremap  <silent> <leader>4           <c-w>L
noremap  <silent> <leader>a           ggvG
noremap! <silent> <leader>a           ggvG
noremap  <silent> <leader>h          :set ft=systemverilog<cr>
noremap  <silent> <leader>s          :set wrap!<cr>
noremap  <silent> <leader>l          :set cuc!<cr>
noremap  <silent> <leader><leader>   :set rnu!<cr>
noremap  <silent> ZA                 :set fen!<cr>
noremap  <silent> <m-leftmouse>       <4-leftmouse>
noremap  <silent> <m-leftdrag>        <leftdrag>
noremap  <silent> <s-scrollwheelup>   <scrollwheelleft>
noremap  <silent> <s-scrollwhelldown> <scrollwheelright>
" }}}

" v mappings {{{
vnoremap <silent> <s-up>              <up>
vnoremap <silent> <s-down>            <down>
vnoremap <silent> <s-left>            <left>
vnoremap <silent> <s-right>           <right>
vnoremap <silent> <leader><leader>    <esc>
" }}}

" i mappings {{{
inoremap <silent> <f2>                <c-o>:cw<cr>
inoremap <silent> <f3>                <c-o>:cp<cr>
inoremap <silent> <f4>                <c-o>:cn<cr>
inoremap <silent> <f5>                <c-o>:up<cr>
inoremap <silent> <leader>'           <c-o>])
inoremap <silent> <leader>[           <right>
inoremap <silent> <leader>]           <end><cr>
inoremap <silent> <leader>\           <end>
inoremap <silent> <m-a>               <c-o>za
inoremap <silent> <m-c>               <c-o>cc
inoremap <silent> <m-d>               <c-o>dd
inoremap <silent> <m-y>               <c-o>yy
inoremap <silent> <m-p>               <c-o>p
inoremap <silent> <m-u>               <c-o>u
inoremap <silent> <m-r>               <c-o><c-r>
inoremap <silent> <m-,>               <c-o>N
inoremap <silent> <m-.>               <c-o>n
inoremap <silent> <c-up>              <esc>ddkPa
inoremap <silent> <c-down>            <esc>ddpa
inoremap <silent> <leader><cr>        <end><cr>
inoremap <silent> <leader><leader>    <esc>
inoremap <silent> <m-LeftMouse>       <4-LeftMouse>
inoremap <silent> <m-LeftDrag>        <LeftDrag>
inoremap <silent> <s-scrollwheelup>   <scrollwheelleft>
inoremap <silent> <s-scrollwhelldown> <scrollwheelright>
" }}}

" settings {{{
set autochdir
set autoindent
set background    =dark
set backspace     =eol,indent,start
set browsedir     =current
set bufhidden     =hide
set clipboard     =autoselect
set colorcolumn   =108
set confirm
set copyindent
set cursorline
set display       =lastline,uhex
set encoding      =utf-8
set expandtab
set fileencoding  =utf-8
set fileencodings =utf-8,gb2312,gb18030,gbk,cp936
set fillchars     =vert:\ ,fold:\ ,diff:\ 
set foldclose     =all
set foldlevel     =0
set foldmethod    =marker
set formatoptions =tcroqan2mB1j
set helpheight    =12
set hidden
set history       =100
set hlsearch
set ignorecase
set incsearch
set laststatus    =2
set lazyredraw
set list
set listchars     =tab:\.\ 
set magic
set matchtime     =10
set mouse         =a
set noautoread
set nocompatible
set noequalalways
set nofoldenable
set noinfercase
set nojoinspaces
set nomousefocus
set nomousehide
set noswapfile
set nostartofline
set nowrap
set nowritebackup
set number
set ruler
set selection     =exclusive
set shiftround
set shiftwidth    =4
set shortmess     =astAW
set showbreak     =>\ 
set showcmd
set showtabline   =0
set smartindent
set smarttab
set smartcase
set softtabstop   =4
set splitbelow
set splitright
set synmaxcol     =1000
set tabstop       =4
set textwidth     =0
set title
set updatetime    =10000
set visualbell
set whichwrap     =<,>,[,],b,s,h,l,~
set wildmenu
set winheight     =4
set winminheight  =4
set winminwidth   =4
set winwidth      =4

if v:version >= 800
    set belloff        =all
    set breakindent
    set breakindentopt =min:20,shift:2
    set shortmess      =acqstAW
endif
" }}}

" gui {{{
if has('gui_running')
    vnoremap <silent> <c-x> "+x
    vnoremap <silent> <c-c> "+y
    nnoremap <silent> <c-v> "+gp
    inoremap <silent> <c-v>  <c-o>"+gp

    set columns    =180
    set guicursor  =n:block-blinkon0,v-ve-o-i-c-ci-sm:ver25-blinkon0,r-cr:hor25-blinkon0
    set guioptions =abeghimr
    set lines      =45

    if has('gui_win32')
        set fileencoding  =gb18030
        set fileencodings =gb18030,gb2312,gbk,cp936,utf-8
        set guifont       =Consolas:h9:cANSI
    elseif has('gui')
        set directory     =/tmp

        if v:version >= 800
            set guifont     =Inconsolata\ 11.5
            set guifontwide =SimSun\ 11.5
        else
            set guifont     =Inconsolata\ 10.5
            set guifontwide =SimSun\ 10.5
        endif
    endif
else
    nnoremap <silent> <c-q> <c-v>

    if has('win32')
        set t_ut      =
        set ttyfast
        set ttymouse  =xterm2
        set ttyscroll =1
    endif
endif
" }}}

" color {{{
filetype    indent plugin on
syntax      enable on
colorscheme gosh

" default
set filetype=systemverilog
" }}}

" autocmd {{{
augroup init
autocmd!
autocmd BufRead,BufNewFile *.v,*.vp,*.vh,*.sv,*.svp,*.svh set filetype=systemverilog
autocmd BufRead,BufNewFile *.s,*.S                        set filetype=arm64asm
autocmd BufRead,BufNewFile *.def,*.mac,*.ih               set filetype=xml
autocmd BufRead,BufNewFile *.org                          set filetype=org

autocmd FileType c,cpp,objc,objcpp  call SetCMap()
autocmd FileType systemverilog      call SetVMap()
autocmd FileType fortran            call SetFMap()
autocmd FileType tex,latex,xml,html call SmallIndent()
augroup end
" }}}

" functions {{{
function! SmallIndent()
    setlocal shiftwidth  =2
    setlocal softtabstop =2
    setlocal tabstop     =2
endfunction

function! SetVMap()
    inoremap <silent> <buffer> <leader><cr> <end>;<cr>
endfunction

function! SetCMap()
    setlocal cindent
    setlocal cinoptions =L-s,:0,=s,ls,g0,N-s,i2s,+2s,(2s,u2s,Us,ws,Ws,M0,js,Js
"   setlocal noexpandtab

    call SetVMap()
endfunction

function! SetFMap()
    call SmallIndent()
    setlocal colorcolumn =72
    setlocal cursorcolumn

    let b:fortran_do_enddo     =1
    let b:fortran_indent_less  =1
    let b:fortran_more_precise =1
endfunction

function! SwapWindow()
    let curr_tab  = tabpagenr()
    let curr_win  = winnr()

    if !exists('g:prev_tab') || !exists('g:prev_win')
        let g:prev_tab = curr_tab
        let g:prev_win = curr_win
        return
    endif

    let curr_view = winsaveview()
    let curr_buf  = bufnr('%')

    execute g:prev_tab . 'tabn'
    execute g:prev_win . 'winc w'

    let prev_view = winsaveview()
    let prev_buf  = bufnr('%')

    execute 'hide buf ' . curr_buf
    call winrestview(curr_view)

    execute curr_tab . 'tabn'
    execute curr_win . 'winc w'

    execute 'hide buf ' . prev_buf
    call winrestview(prev_view)

    unlet g:prev_tab
    unlet g:prev_win
endfunction

noremap <silent> <leader><space> :call SwapWindow()<cr>
" }}}

" plugins {{{
call plug#begin('~/.vim/plug')

Plug 'Raimondi/delimitMate'
Plug 'junegunn/vim-easy-align'
Plug 'salsifis/vim-transpose'
Plug 'tpope/vim-surround'

Plug 'ap/vim-buftabline'
Plug 'ervandew/supertab'

call plug#end()

let g:delimitMate_expand_cr =1
let g:delimitMate_quotes    =" ' \" "

map <silent> <leader>e <Plug>(EasyAlign)
" }}}
