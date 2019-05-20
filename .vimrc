" mappings {{{
let mapleader=";"

noremap  *                  :vim /\<<c-r><c-w>\>/gj %<cr> :cw<cr>*
noremap  <f2>               :cw<cr>
noremap  <f3>               :cp<cr>
noremap  <f4>               :cn<cr>
noremap  <f5>               :w<cr>
noremap  <f6>               :source ~/.vimrc<cr>
noremap  <f12>              :cal 
noremap  <c-up>              ddkP
noremap  <c-down>            ddp
noremap  <c-left>           :bp<cr>
noremap  <c-right>          :bn<cr>
noremap  <c-pageup>         :tabp<cr>
noremap  <c-pagedown>       :tabn<cr>
noremap  <s-up>              v<up>
noremap  <s-down>            v<down>
noremap  <s-left>            v<left>
noremap  <s-right>           v<right>
noremap  <space>             i
noremap  <leader><cr>       :e 
noremap  <leader>-          :new 
noremap  <leader>\          :vne 
noremap  <leader>=          :vert diffsplit 
noremap  <leader>t          :tabe 
noremap  <leader>w          :bw<cr>
noremap  <leader>q          :q<cr>
noremap  <leader>c          :sp<cr>
noremap  <leader>v          :vs<cr>
noremap  <leader>f          :vert wincmd f<cr>
noremap  <leader>d           <c-w>f
noremap  <leader>a           ggvG
noremap! <leader>a           ggvG
noremap  <leader><space>     ggdG
noremap  <leader>h          :set ft=systemverilog<cr>
noremap  <leader>s          :set wrap!<cr>
noremap  <leader>l          :set cuc!<cr>
noremap  <leader><leader>   :set rnu!<cr>
noremap  ZA                 :set fen!<cr>
noremap  <m-leftmouse>       <4-leftmouse>
noremap  <m-leftdrag>        <leftdrag>
noremap  <s-scrollwheelup>   <scrollwheelleft>
noremap  <s-scrollwhelldown> <scrollwheelright>
" }}}

" v mappings {{{
vnoremap <s-up>              <up>
vnoremap <s-down>            <down>
vnoremap <s-left>            <left>
vnoremap <s-right>           <right>
vnoremap <leader><leader>    <esc>
" }}}

" i mappings {{{
inoremap <f2>                <c-o>:cw<cr>
inoremap <f3>                <c-o>:cp<cr>
inoremap <f4>                <c-o>:cn<cr>
inoremap <f5>                <c-o>:w<cr>
inoremap <leader>'           <c-o>])
inoremap <leader>[           <right>
inoremap <leader>]           <end><cr>
inoremap <leader>\           <end>
inoremap <m-a>               <c-o>za
inoremap <m-c>               <c-o>cc
inoremap <m-d>               <c-o>dd
inoremap <m-y>               <c-o>yy
inoremap <m-p>               <c-o>p
inoremap <m-u>               <c-o>u
inoremap <m-r>               <c-o><c-r>
inoremap <m-,>               <c-o>N
inoremap <m-.>               <c-o>n
inoremap <c-up>              <esc>ddkPa
inoremap <c-down>            <esc>ddpa
inoremap <leader><cr>        <end><cr>
inoremap <leader><leader>    <esc>
inoremap <m-LeftMouse>       <4-LeftMouse>
inoremap <m-LeftDrag>        <LeftDrag>
inoremap <s-scrollwheelup>   <scrollwheelleft>
inoremap <s-scrollwhelldown> <scrollwheelright>
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
set formatoptions =tcroqanmB1j
set helpheight    =12
set hidden
set history       =100
set hlsearch
set ignorecase
set incsearch
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
set tabstop       =4
set title
set ttyfast
set updatetime    =10000
set whichwrap     =<,>,[,],b,s,h,l,~
set wildmenu

if v:version >= 800
    set belloff        =all
    set breakindent
    set breakindentopt =min:20,shift:2
    set shortmess      =acqstAW
endif
" }}}

" gui_running {{{
if has("gui_running")
    vnoremap <c-x> "+x
    vnoremap <c-c> "+y
    nnoremap <c-v> "+gp
    inoremap <c-v>  <c-o>"+gp

    set columns    =180
    set guicursor  =n:block-blinkon0,v-ve-o-i-c-ci-sm:ver25-blinkon0,r-cr:hor25-blinkon0
    set guioptions =abeghir
    set lines      =45

    if has("gui_win32")
        set noswapfile
        set fileencoding  =gb18030
        set fileencodings =gb18030,gb2312,gbk,cp936,utf-8
        set guifont       =Consolas:h11:cANSI
    elseif has('gui')
        set directory     =/tmp
        set guifont       =Inconsolata\ 11.5
        set guifontwide   =SimSun\ 11.5
    endif
else
    nnoremap <c-q> <c-v>
endif
" }}}

" filetype syntax {{{
filetype    indent plugin on
syntax      enable on
colorscheme gosh

" default
set filetype=systemverilog
" }}}

" init autocmd {{{
augroup init
autocmd!
autocmd BufRead,BufNewFile *.svp,*.svh,*.vp,*.vh set filetype=systemverilog
autocmd BufRead,BufNewFile *.S,*.s               set filetype=arm64asm
autocmd BufRead,BufNewFile *.def,*.ih,*.mac      set filetype=xml

autocmd FileType c,cpp,objc,objcpp  call Setcmap()
autocmd FileType systemverilog      call Setvmap()
autocmd FileType fortran            call Setfmap()
autocmd FileType tex,latex,xml,html call SmallIndent()
augroup end
" }}}

" functions {{{
function! Setcmap()
    setlocal cindent
    setlocal cinoptions =L-s,:0,=s,ls,g0,N-s,i2s,+2s,(2s,u2s,Us,ws,Ws,M0,js,Js
    setlocal noexpandtab

    inoremap <buffer> <leader><cr> <end>;<cr>
endfunction

function! Setvmap()
    inoremap <buffer> <leader><cr> <end>;<cr>
endfunction

function! Setfmap()
    call SmallIndent()
    setlocal colorcolumn =72
    setlocal cursorcolumn

    let b:fortran_do_enddo     =1
    let b:fortran_indent_less  =1
    let b:fortran_more_precise =1
endfunction

function! SmallIndent()
    setlocal shiftwidth  =2
    setlocal softtabstop =2
    setlocal tabstop     =2
endfunction
" }}}

" plugin configs {{{
let g:delimitMate_expand_cr =1
let g:delimitMate_quotes    =" \" ' "

map <leader>e <Plug>(EasyAlign)
" }}}
