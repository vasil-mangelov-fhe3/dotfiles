"---------------------------------------------------------------------------
" Edit:
"

" Smart insert tab setting.
set smarttab
" Don't exchange tab to spaces.
set noexpandtab
" Substitute <Tab> with blanks.
set tabstop=4
" Spaces instead <Tab>.
set softtabstop=4
" Autoindent width.
set shiftwidth=4
" Round indent by shiftwidth.
set shiftround

set autoindent
"wrapping
set wrap		"wrap lines
set linebreak	"wrap lines at convenient points
" Enable modeline.
set modeline
set modelines=5
"show linenumbers
set number

" Use clipboard register.
if has('unnamedplus')
	set clipboard& clipboard+=unnamedplus
else
	set clipboard& clipboard+=unnamed
endif

" Enable backspace delete indent and newline.
set backspace=indent,eol,start

" Highlight parenthesis.
set showmatch
" Highlight when CursorMoved.
set cpoptions-=m
set matchtime=3
" Highlight <>.
set matchpairs+=<:>

" Display another buffer when current buffer isn't saved.
set hidden

"turn on spell checking
set spell

" Auto reload if file is changed.
"set autoread

" Ignore case on insert completion.
set infercase

" Search home directory path on cd.
" But can't complete.
" set cdpath+=~

" Enable folding.
set nofoldenable
" set foldmethod=expr
set foldmethod=marker
" Show folding level.
set foldcolumn=1
set fillchars=vert:\|

if exists('*FoldCCtext')
	" Use FoldCCtext().
	set foldtext=FoldCCtext()
endif

" Use vimgrep.
"set grepprg=internal
" Use grep.
set grepprg=grep\ -inH

" Exclude = from isfilename.
set isfname-==

" Keymapping timeout.
set timeout timeoutlen=3000 ttimeoutlen=100

" CursorHold time.
set updatetime=1000

" Set swap directory.
set directory=~/.vim/swapfiles

if v:version >= 703
	set undofile
	set undodir=~/.vim/undofiles
	set undolevels=1000
	set undoreload=10000
	set viminfo='50,f1,<500,@100,h,%,/50,:100,n~/.vim/.viminfo
	set backupdir=~/.vim/backupfiles
	set colorcolumn=100
endif

if v:version < 703 || (v:version == 7.3 && !has('patch336'))
	" Vim's bug.
	set notagbsearch
endif

" Enable virtualedit in visual block mode.
set virtualedit=block

" Set keyword help.
set keywordprg=:help

" Check timestamp more for 'autoread'.
autocmd MyAutoCmd WinEnter * checktime

" Disable paste.
autocmd MyAutoCmd InsertLeave *
			\ if &paste | set nopaste mouse=a | echo 'nopaste' | endif |
		\ if &l:diff | diffupdate | endif

" Update diff.
autocmd MyAutoCmd InsertLeave * if &l:diff | diffupdate | endif

" Use autofmt.
set formatexpr=autofmt#compat#formatexpr()
