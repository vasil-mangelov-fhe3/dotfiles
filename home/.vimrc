set nocompatible

"---------------------------------------------------------------------------
" Initialize:
"

" Note: Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

function! s:source_rc(path)
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

call s:source_rc('init.rc.vim')

call neobundle#begin(expand('~/.vim/bundle/'))

if neobundle#has_cache()
	NeoBundleLoadCache
else
	call s:source_rc('neobundle.rc.vim')
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


"---------------------------------------------------------------------------
" Encoding:
"

set fileformat=unix
set fileformats=unix,dos,mac

"---------------------------------------------------------------------------
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

"---------------------------------------------------------------------------
" Edit:
"

call s:source_rc('edit.rc.vim')

"---------------------------------------------------------------------------
" View:
"

call s:source_rc('view.rc.vim')

"---------------------------------------------------------------------------
" FileType:
"

call s:source_rc('filetype.rc.vim')

"---------------------------------------------------------------------------
" Plugin:
"

call s:source_rc('plugins.rc.vim')

"---------------------------------------------------------------------------
" Mappings:
"

call s:source_rc('mappings.rc.vim')

"---------------------------------------------------------------------------
" Platform:
"

if s:is_windows
	call s:source_rc('windows.rc.vim')
else
	call s:source_rc('unix.rc.vim')
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

" Defaults {

"Try and recognize line endings in that order
"vertical/horizontal scroll off settings
set scrolloff=3
set sidescrolloff=7
set sidescroll=1
"tell the term has 256 colors
if &term =~ '256color'
	set t_ut=
endif
"}

" Misc {
" allows cursor change in tmux mode
if exists('$TMUX')
	let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
	let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
	let &t_SI = "\<Esc>]50;CursorShape=1\x7"
	let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif
"}

"---------------------------------------------------------------------------
" Commands:
"

function! DiffWithSaved()
	let filetype=&ft
	diffthis
	vnew | r # | normal! 1Gdd
	diffthis
	execute "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction

" When you press <leader>r you can search and replace the selected text
function! VisualSelection(direction) range
	let l:saved_reg = @"
	execute "normal! vgvy"

	let l:pattern = escape(@", '\\/.*$^~[]')
	let l:pattern = substitute(l:pattern, "\n$", "", "")

	if a:direction == 'b'
		execute "normal ?" . l:pattern . "^M"
	elseif a:direction == 'gv'
		call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.')
	elseif a:direction == 'replace'
		call CmdLine("%s" . '/'. l:pattern . '/')
	elseif a:direction == 'f'
		execute "normal /" . l:pattern . "^M"
	endif

	let @/ = l:pattern
	let @" = l:saved_reg
endfunction
vnoremap <silent> <leader>r :call VisualSelection('replace')<CR>

" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX
" files.
function! AppendModeline()
	let l:modeline = printf(" vim: set ts=%d sw=%d tw=%d %set :",
				\ &tabstop, &shiftwidth, &textwidth, &expandtab ? '' : 'no')
	let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
	call append(line("$"), l:modeline)
endfunction
nnoremap <silent> <Leader>ml :call AppendModeline()<CR>

"visual search mappings
function! s:VSetSearch()
	let temp = @@
	norm! gvy
	let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
	let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>

"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
function! SetCursorPosition()
	if &filetype !~ 'svn\|commit\c'
		if line("'\"") > 0 && line("'\"") <= line("$")
			exe "normal! g`\""
			normal! zz
		endif
	end
endfunction
autocmd BufReadPost * call SetCursorPosition()
