hi clear
if exists("syntax_on")
	syntax reset
endif
let g:colors_name="gosh"

set background=dark

highlight	normal			guifg=#d0d0d0	guibg=#1c1c1c	gui=NONE		ctermfg=252		ctermbg=234		cterm=NONE
highlight	comment			guifg=#808080	guibg=NONE		gui=italic		ctermfg=244		ctermbg=NONE	cterm=NONE
highlight	constant		guifg=#5f87d7	guibg=NONE		gui=NONE		ctermfg=68		ctermbg=NONE	cterm=NONE
highlight	number			guifg=#afd7af	guibg=NONE		gui=NONE		ctermfg=151		ctermbg=NONE	cterm=NONE
highlight	boolean			guifg=#afd7af	guibg=NONE		gui=NONE		ctermfg=151		ctermbg=NONE	cterm=NONE
highlight	float			guifg=#afd7af	guibg=NONE		gui=NONE		ctermfg=151		ctermbg=NONE	cterm=NONE
highlight	string			guifg=#87afd7	guibg=NONE		gui=italic		ctermfg=110		ctermbg=NONE	cterm=NONE
highlight	character		guifg=#87afd7	guibg=NONE		gui=italic		ctermfg=110		ctermbg=NONE	cterm=NONE
highlight	identifier		guifg=#d7afd7	guibg=NONE		gui=NONE		ctermfg=182		ctermbg=NONE	cterm=NONE
highlight	function		guifg=#d7afd7	guibg=NONE		gui=NONE		ctermfg=182		ctermbg=NONE	cterm=NONE
highlight	statement		guifg=#afafff	guibg=NONE		gui=NONE		ctermfg=147		ctermbg=NONE	cterm=NONE
highlight	keyword			guifg=#afafff	guibg=NONE		gui=NONE		ctermfg=147		ctermbg=NONE	cterm=NONE
highlight	operator		guifg=#afafff	guibg=NONE		gui=NONE		ctermfg=147		ctermbg=NONE	cterm=NONE
highlight	conditional		guifg=#afafff	guibg=NONE		gui=NONE		ctermfg=147		ctermbg=NONE	cterm=NONE
highlight	repeat			guifg=#afafff	guibg=NONE		gui=NONE		ctermfg=147		ctermbg=NONE	cterm=NONE
highlight	label			guifg=#afafff	guibg=NONE		gui=NONE		ctermfg=147		ctermbg=NONE	cterm=NONE
highlight	exception		guifg=#afafff	guibg=NONE		gui=NONE		ctermfg=147		ctermbg=NONE	cterm=NONE
highlight	matchparen		guifg=#afafff	guibg=#444444	gui=NONE		ctermfg=147		ctermbg=238		cterm=NONE
highlight	preproc			guifg=#d7d7af	guibg=NONE		gui=NONE		ctermfg=187		ctermbg=NONE	cterm=NONE
highlight	include			guifg=#d7d7af	guibg=NONE		gui=NONE		ctermfg=187		ctermbg=NONE	cterm=NONE
highlight	define			guifg=#d7d7af	guibg=NONE		gui=NONE		ctermfg=187		ctermbg=NONE	cterm=NONE
highlight	macro			guifg=#d7d7af	guibg=NONE		gui=NONE		ctermfg=187		ctermbg=NONE	cterm=NONE
highlight	precondit		guifg=#d7d7af	guibg=NONE		gui=NONE		ctermfg=187		ctermbg=NONE	cterm=NONE
highlight	type			guifg=#5f87af	guibg=NONE		gui=NONE		ctermfg=67		ctermbg=NONE	cterm=NONE
highlight	typedef			guifg=#5f87af	guibg=NONE		gui=NONE		ctermfg=67		ctermbg=NONE	cterm=NONE
highlight	structure		guifg=#5f87af	guibg=NONE		gui=NONE		ctermfg=67		ctermbg=NONE	cterm=NONE
highlight	storageclass	guifg=#5f87af	guibg=NONE		gui=NONE		ctermfg=67		ctermbg=NONE	cterm=NONE
highlight	special			guifg=#dfafdf	guibg=NONE		gui=NONE		ctermfg=182		ctermbg=NONE	cterm=NONE
highlight	specialchar		guifg=#dfafdf	guibg=NONE		gui=NONE		ctermfg=182		ctermbg=NONE	cterm=NONE
highlight	specialcomment	guifg=#dfafdf	guibg=NONE		gui=NONE		ctermfg=182		ctermbg=NONE	cterm=NONE
highlight	specialkey		guifg=#444444	guibg=NONE		gui=NONE		ctermfg=238		ctermbg=NONE	cterm=NONE
highlight	tag				guifg=#ffffaf	guibg=NONE		gui=italic		ctermfg=229		ctermbg=NONE	cterm=NONE
highlight	debug			guifg=#ffffaf	guibg=NONE		gui=italic		ctermfg=229		ctermbg=NONE	cterm=NONE
highlight	delimiter		guifg=#dfafdf	guibg=NONE		gui=NONE		ctermfg=182		ctermbg=NONE	cterm=NONE
highlight	todo			guifg=#ffffaf	guibg=NONE		gui=italic		ctermfg=229		ctermbg=NONE	cterm=NONE
highlight	error			guifg=#ff5f5f	guibg=NONE		gui=NONE		ctermfg=203		ctermbg=NONE	cterm=NONE
highlight	linenr			guifg=#808080	guibg=#303030	gui=NONE		ctermfg=244		ctermbg=236		cterm=NONE
highlight	cursorlinenr	guifg=#d7d7af	guibg=#1c1c1c	gui=NONE		ctermfg=187		ctermbg=234		cterm=NONE
highlight	cursor			guifg=NONE		guibg=#a8a8a8	gui=NONE		ctermfg=NONE	ctermbg=248		cterm=NONE
highlight	cursorim		guifg=NONE		guibg=#a8a8a8	gui=NONE		ctermfg=NONE	ctermbg=248		cterm=NONE
highlight	cursorline		guifg=NONE		guibg=#444444	gui=NONE		ctermfg=NONE	ctermbg=238		cterm=NONE
highlight	cursorcolumn	guifg=NONE		guibg=#444444	gui=NONE		ctermfg=NONE	ctermbg=238		cterm=NONE
highlight	colorcolumn		guifg=NONE		guibg=#444444	gui=NONE		ctermfg=NONE	ctermbg=238		cterm=NONE
highlight	signcolumn		guifg=#808080	guibg=#444444	gui=NONE		ctermfg=244		ctermbg=238		cterm=NONE
highlight	diffadd			guifg=NONE		guibg=#303030	gui=NONE		ctermfg=NONE	ctermbg=236		cterm=NONE
highlight	diffchange		guifg=NONE		guibg=#303030	gui=NONE		ctermfg=NONE	ctermbg=236		cterm=NONE
highlight	diffdelete		guifg=NONE		guibg=#303030	gui=NONE		ctermfg=NONE	ctermbg=236		cterm=NONE
highlight	difftext		guifg=NONE		guibg=#303030	gui=NONE		ctermfg=NONE	ctermbg=236		cterm=NONE
highlight	folded			guifg=NONE		guibg=#303030	gui=NONE		ctermfg=NONE	ctermbg=236		cterm=NONE
highlight	foldcolumn		guifg=NONE		guibg=#303030	gui=NONE		ctermfg=NONE	ctermbg=236		cterm=NONE
highlight	pmenu			guifg=NONE		guibg=#444444	gui=NONE		ctermfg=NONE	ctermbg=238		cterm=NONE
highlight	pmenusel		guifg=NONE		guibg=#6c6c6c	gui=NONE		ctermfg=NONE	ctermbg=242		cterm=NONE
highlight	pmenusbar		guifg=#6c6c6c	guibg=#6c6c6c	gui=NONE		ctermfg=242		ctermbg=242		cterm=NONE
highlight	pmenuthumb		guifg=#6c6c6c	guibg=#6c6c6c	gui=NONE		ctermfg=242		ctermbg=242		cterm=NONE
highlight	statusline		guifg=#1c1c1c	guibg=#6c6c6c	gui=NONE		ctermfg=234		ctermbg=242		cterm=NONE
highlight	statuslinenc	guifg=#303030	guibg=#6c6c6c	gui=NONE		ctermfg=236		ctermbg=242		cterm=NONE
highlight	vertsplit		guifg=#6c6c6c	guibg=#6c6c6c	gui=NONE		ctermfg=242		ctermbg=242		cterm=NONE
highlight	spellbad		guifg=NONE		guibg=#303030	gui=undercurl	ctermfg=NONE	ctermbg=236		cterm=NONE
highlight	spellcap		guifg=NONE		guibg=#303030	gui=undercurl	ctermfg=NONE	ctermbg=236		cterm=NONE
highlight	spellrare		guifg=NONE		guibg=#303030	gui=undercurl	ctermfg=NONE	ctermbg=236		cterm=NONE
highlight	spelllocal		guifg=NONE		guibg=#303030	gui=undercurl	ctermfg=NONE	ctermbg=236		cterm=NONE
highlight	tabline			guifg=#d0d0d0	guibg=#1c1c1c	gui=NONE		ctermfg=252		ctermbg=234		cterm=NONE
highlight	tablinefill		guifg=#d0d0d0	guibg=#1c1c1c	gui=NONE		ctermfg=252		ctermbg=234		cterm=NONE
highlight	tablinesel		guifg=#d0d0d0	guibg=#444444	gui=NONE		ctermfg=252		ctermbg=238		cterm=NONE
highlight	warningmsg		guifg=#ff8787	guibg=NONE		gui=NONE		ctermfg=210		ctermbg=NONE	cterm=NONE
highlight	errormsg		guifg=#ff5f5f	guibg=NONE		gui=NONE		ctermfg=203		ctermbg=NONE	cterm=NONE
highlight	moremsg			guifg=#afafff	guibg=NONE		gui=NONE		ctermfg=147		ctermbg=NONE	cterm=NONE
highlight	modemsg			guifg=#afafff	guibg=NONE		gui=NONE		ctermfg=147		ctermbg=NONE	cterm=NONE
highlight	question		guifg=#afafff	guibg=NONE		gui=NONE		ctermfg=147		ctermbg=NONE	cterm=NONE
highlight	title			guifg=#afafff	guibg=NONE		gui=NONE		ctermfg=147		ctermbg=NONE	cterm=NONE
highlight	wildmenu		guifg=#afafff	guibg=#6c6c6c	gui=NONE		ctermfg=147		ctermbg=242		cterm=NONE
highlight	nontext			guifg=#444444	guibg=NONE		gui=NONE		ctermfg=238		ctermbg=NONE	cterm=NONE
highlight	incsearch		guifg=NONE		guibg=#6c6c6c	gui=bold		ctermfg=NONE	ctermbg=242		cterm=NONE
highlight	search			guifg=NONE		guibg=#6c6c6c	gui=bold		ctermfg=NONE	ctermbg=242		cterm=NONE
highlight	visual			guifg=NONE		guibg=#444444	gui=NONE		ctermfg=NONE	ctermbg=238		cterm=NONE
highlight	visualnos		guifg=NONE		guibg=#444444	gui=NONE		ctermfg=NONE	ctermbg=238		cterm=NONE
highlight	directory		guifg=#87afff	guibg=NONE		gui=NONE		ctermfg=111		ctermbg=NONE	cterm=NONE
highlight	ignore			guifg=#1c1c1c	guibg=NONE		gui=NONE		ctermfg=234		ctermbg=NONE	cterm=NONE
highlight	underlined		guifg=NONE		guibg=NONE		gui=underline	ctermfg=NONE	ctermbg=NONE	cterm=NONE
