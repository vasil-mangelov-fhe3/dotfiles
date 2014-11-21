"---------------------------------------------------------------------------
" View:
"

" Anywhere SID.
function! s:SID_PREFIX()
	return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction

" Show <TAB> and <CR>
set list
if IsWindows()
	set listchars=tab:>.,trail:-,extends:>,precedes:<
else
	set listchars=tab:>.,trail:-,extends:»,precedes:«,nbsp:.
endif
" Do not wrap long line.
set nowrap
" Wrap conditions.
set whichwrap+=h,l,<,>,[,],b,s,~
" Always display statusline.
set laststatus=2
" Not show command on statusline.
set showcmd
" Turn down a long line appointed in 'breakat'
set linebreak
set showbreak=>\
set breakat=\ \	;:,!?

" Do not display greetings message at the time of Vim start.
set shortmess=aTI

" TMUX fix {{{
" tell vim that the term has 256 colors
if &term =~ '256color'
	set t_ut=
endif
" allows cursor change in tmux mode
if exists('$TMUX')
	let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
	let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
	let &t_SI = "\<Esc>]50;CursorShape=1\x7"
	let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif
"}}}

" Disable bell.
set t_vb=
set novisualbell

" Display candidate supplement.
set nowildmenu
set wildmode=list:longest,full
set wildignore=*.o,*.obj,*.pyc.,*.dll "stuff to ignore when tab completing
" Increase history amount.
set history=1000
" Display all the information of the tag by the supplement of the Insert mode.
set showfulltag
" Can supplement a tag in a command-line.
set wildoptions=tagfile

" Disable menu
let g:did_install_default_menus = 1

if !&verbose
	" Enable spell check.
	set spelllang=en_us
	" Enable de_de support.
	"set spelllang+=de_de
endif

" Completion setting.
set completeopt=menuone
" Don't complete from other buffer.
"set complete=.
set complete=.,w,b,i,t
" Set popup menu max height.
set pumheight=20

" Report changes.
set report=0

" Maintain a current line at the time of movement as much as possible.
set nostartofline

" Splitting a window will put the new window below the current one.
set splitbelow
" Splitting a window will put the new window right the current one.
set splitright
" Set minimal width for current window.
set winwidth=30
" Set minimal height for current window.
" set winheight=20
set winheight=1
" Set maximam maximam command line window.
set cmdwinheight=5
" No equal window size.
set noequalalways

" Adjust window size of preview and help.
set previewheight=8
set helpheight=12

" Don't redraw while macro executing.
set lazyredraw
set ttyfast

" When a line is long, do not omit it in @.
set display=lastline
" Display an invisible letter with hex format.
"set display+=uhex

" View setting.
set viewdir=$CACHE/vim_view viewoptions-=options viewoptions+=slash,unix

function! s:strwidthpart(str, width) "{{{
	if a:width <= 0
		return ''
	endif
	let ret = a:str
	let width = s:wcswidth(a:str)
	while width > a:width
		let char = matchstr(ret, '.$')
		let ret = ret[: -1 - len(char)]
		let width -= s:wcswidth(char)
	endwhile

	return ret
endfunction"}}}

if v:version >= 703
	" For conceal.
	set conceallevel=2 concealcursor=iv

	set colorcolumn=100

	" Use builtin function.
	function! s:wcswidth(str)
		return strwidth(a:str)
	endfunction
	finish
endif

function! s:wcswidth(str)
	if a:str =~# '^[\x00-\x7f]*$'
		return strlen(a:str)
	end

	let mx_first = '^\(.\)'
	let str = a:str
	let width = 0
	while 1
		let ucs = char2nr(substitute(str, mx_first, '\1', ''))
		if ucs == 0
			break
		endif
		let width += s:_wcwidth(ucs)
		let str = substitute(str, mx_first, '', '')
	endwhile
	return width
endfunction

" UTF-8 only.
function! s:_wcwidth(ucs)
	let ucs = a:ucs
	if (ucs >= 0x1100
				\  && (ucs <= 0x115f
				\  || ucs == 0x2329
				\  || ucs == 0x232a
				\  || (ucs >= 0x2e80 && ucs <= 0xa4cf && ucs != 0x303f)
				\  || (ucs >= 0xac00 && ucs <= 0xd7a3)
				\  || (ucs >= 0xf900 && ucs <= 0xfaff)
				\  || (ucs >= 0xfe30 && ucs <= 0xfe6f)
				\  || (ucs >= 0xff00 && ucs <= 0xff60)
				\  || (ucs >= 0xffe0 && ucs <= 0xffe6)
				\  || (ucs >= 0x20000 && ucs <= 0x2fffd)
				\  || (ucs >= 0x30000 && ucs <= 0x3fffd)
				\  ))
		return 2
	endif
	return 1
endfunction
"}}}

" View logfiles as ft messages
autocmd BufNewFile,BufReadPost *.log :set filetype=messages
autocmd BufNewFile,BufReadPost /var/log/* :set filetype=messages

