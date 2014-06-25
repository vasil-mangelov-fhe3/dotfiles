" NemesisRE's .vimrc (shameless taken from https://github.com/Shougo/shougo-s-github)
"--------------------------------------------------------------------------------------------------

"--------------------------------------------------------------------------------------------------
" Initialize:
"

" Note: Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

function! g:source_rc(path)
	execute 'source' fnameescape(expand('~/.vim/rc/' . a:path))
endfunction

let s:is_windows = has('win16') || has('win32') || has('win64')
let s:is_cygwin = has('win32unix')
let s:is_sudo = $SUDO_USER != '' && $USER !=# $SUDO_USER
			\ && $HOME !=# expand('~'.$USER)
			\ && $HOME ==# expand('~'.$SUDO_USER)

function! IsWindows()
	return s:is_windows
endfunction

function! IsMac()
	return !s:is_windows && !s:is_cygwin
				\ && (has('mac') || has('macunix') || has('gui_macvim') ||
				\   (!executable('xdg-open') &&
				\     system('uname') =~? '^darwin'))
endfunction

call g:source_rc('init.rc.vim')

call neobundle#begin(expand('~/.vim/bundle/'))

if neobundle#has_cache()
	NeoBundleLoadCache
else
	call g:source_rc('neobundle.rc.vim')
	NeoBundleSaveCache
endif

NeoBundleLocal ~/.vim/bundle

call neobundle#end()

"load ftplugins and indent files
filetype plugin indent on
"turn on syntax highlighting
syntax on

" Installation check.
NeoBundleCheck


"--------------------------------------------------------------------------------------------------
" Encoding:
"

set fileformat=unix
set fileformats=unix,dos,mac

"--------------------------------------------------------------------------------------------------
" Search:
"

" Ignore the case of normal letters.
set ignorecase
" If the search pattern contains upper case characters, override ignorecase option.
set smartcase

" Enable incremental search.
set incsearch
" Don't highlight search result.
set hlsearch

" Searches wrap around the end of the file.
set wrapscan

"--------------------------------------------------------------------------------------------------
" Edit:
"

call g:source_rc('edit.rc.vim')

"--------------------------------------------------------------------------------------------------
" View:
"

call g:source_rc('view.rc.vim')

"--------------------------------------------------------------------------------------------------
" FileType:
"

call g:source_rc('filetype.rc.vim')

"--------------------------------------------------------------------------------------------------
" Plugin:
"

call g:source_rc('plugins.rc.vim')

"--------------------------------------------------------------------------------------------------
" Mappings:
"

call g:source_rc('mappings.rc.vim')

"--------------------------------------------------------------------------------------------------
" Platform:
"

if s:is_windows
	call g:source_rc('windows.rc.vim')
else
	call g:source_rc('unix.rc.vim')
endif

" Using the mouse on a terminal.
if has('mouse')
	set mouse=a
	if has('mouse_sgr') || v:version > 703 ||
				\ v:version == 703 && has('patch632')
		set ttymouse=sgr
	else
		set ttymouse=xterm2
	endif

	" Paste.
	nnoremap <RightMouse> "+p
	xnoremap <RightMouse> "+p
	inoremap <RightMouse> <C-r><C-o>+
	cnoremap <RightMouse> <C-r>+
endif
"}

"--------------------------------------------------------------------------------------------------
" Commands:
"

function! DiffWithSaved()
" WIP
"	if &diff
"		execute "normal \<c-w>h<c-w>c"
"		diffoff
"	else
		let filetype=&ft
		diffthis
		vnew | r # | normal! 1Gdd
		diffthis
		execute "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
"	endif
endfunction

"jump to last cursor position when opening a file, dont do it when writing a commit log entry
function! SetCursorPosition()
	if &filetype !~ 'svn\|commit\c'
		if line("'\"") > 0 && line("'\"") <= line("$")
			exe "normal! g`\""
			normal! zz
		endif
	end
endfunction
autocmd BufReadPost * call SetCursorPosition()

"--------------------------------------------------------------------------------------------------
" GUI:
"

if has('gui_running')
  call g:source_rc('gui.rc.vim')
endif

"--------------------------------------------------------------------------------------------------
" Others:
"

" If true Vim master, use English help file.
set helplang& helplang=en

" Default home directory.
let t:cwd = getcwd()

call neobundle#call_hook('on_source')

set secure

" vim: foldmethod=marker
