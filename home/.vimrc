" Basics {
	set nocompatible

	" pathogen {
		"Load pathogen
		runtime bundle/vim-pathogen/autoload/pathogen.vim
		"To disable a plugin, add it's bundle name to the following list
		let g:pathogen_disabled = []

		if !( has('lua') && (v:version > 703 || v:version == 703 && has('patch885')) )
			call add(g:pathogen_disabled, 'neocomplete')
		endif

		if v:version <= 703
			call add(g:pathogen_disabled, 'easymotion')
			call add(g:pathogen_disabled, 'gundo')
		endif

		if v:version < '702'
			call add(g:pathogen_disabled, 'syntastic')
			call add(g:pathogen_disabled, 'tagbar')
		endif

		if !executable("ctags")
			call add(g:pathogen_disabled, 'tagbar')
		endif

		call pathogen#infect()
		call pathogen#helptags()
	"}

	" Defaults {
		if v:version >= 703
			"undo settings
			set undofile
			set undodir=~/.vim/undofiles
			set undolevels=1000
			set undoreload=10000
			set viminfo='50,f1,<500,@100,h,%,/50,:100,n~/.vim/.viminfo
			set backupdir=~/.vim/backupfiles
			set directory=~/.vim/swapfiles
			set colorcolumn=100 "mark the ideal max text width
		endif

		"allow backspacing over everything in insert mode
		set backspace=indent,eol,start
		"store lots of :cmdline history
		set history=1000
		"show cmdline
		set showcmd
		set laststatus=2
		" When I close a tab, remove the buffer
		set hidden
		"show linenumbers
		set number
		"display tabs and trailing spaces
		set list
		set listchars=tab:>.,trail:.,extends:#,nbsp:.
		"search settings
		set incsearch
		set hlsearch
		set ignorecase
		set smartcase
		"wrapping
		set wrap		"dont wrap lines
		set linebreak	"wrap lines at convenient points
		"default indent settings
		set shiftwidth=4
		set tabstop=4
		set softtabstop=4
		set noexpandtab
		set autoindent
		"folding settings
		set foldmethod=indent
		set foldlevel=1
		set nofoldenable
		"enable wildmenu
		set wildmenu				"enable ctrl-n and ctrl-p to scroll thru matches
		set wildmode=list:longest	"make cmdline tab completion similar to bash
		set wildignore=*.o,*.obj,*.pyc.,*.dll "stuff to ignore when tab completing
		"enable modeline
		set modeline
		set modelines=5
		"Try and recognize line endings in that order
		set ffs=unix,dos,mac
		"vertical/horizontal scroll off settings
		set scrolloff=3
		set sidescrolloff=7
		set sidescroll=1
		"load ftplugins and indent files
		filetype on
		filetype plugin on
		filetype indent on
		"turn on syntax highlighting
		syntax on
		"turn on spell checking
		set spell
		"some stuff to get the mouse going in term
		set mouse=a
		set ttymouse=xterm2
		"tell the term has 256 colors
		set t_Co=256
		if &term =~ '256color'
			set t_ut=
		endif
	"}

	" Key mappings {
		let mapleader = ","
		let g:mapleader = ","
		map <F1> <Nop>
		nnoremap <silent> <F2> :NERDTreeToggle<CR>
		:imap <F2> <C-o>:NERDTreeToggle<CR>
		nnoremap <silent> <F3> :TagbarToggle<CR>
		:imap <F3> <C-o>:TagbarToggle<CR>
		nnoremap <silent> <F4> :CtrlPBuffer<CR>
		:imap <F4> <C-o>:CtrlPBuffer<CR>
		if v:version >= 703
			nnoremap <silent> <F5> :GundoToggle<CR>
			:imap <F5> <C-o>:GundoToggle<CR>
		endif
		nnoremap <silent> <F6> :set invnumber invlist<CR>
		:imap <F6> <C-o>:set invnumber invlist<CR>
		set pastetoggle=<F7>
		nnoremap <silent> <F11> :setlocal spell! spell?<CR>
		:imap <F11> <C-o>:setlocal spell! spell?<CR>
		nnoremap <silent> <F12> :call DiffWithSaved()<CR>
		" Next Tab
		nnoremap <silent> <C-Right> :tabnext<CR>
		" Previous Tab
		nnoremap <silent> <C-Left> :tabprevious<CR>
		" New Tab
		nnoremap <silent> <C-t> :tabnew<CR>
		"make <c-l> clear the highlight as well as redraw
		nnoremap <C-L> :nohls<CR><C-L>
		inoremap <C-L> <C-O>:nohls<CR>
		"map Q to something useful
		nnoremap Q gq
		"make Y consistent with C and D
		nnoremap Y y$
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
"}

" Plugins {
	" ctrlp {
		set runtimepath^=~/.vim/bundle/ctrlp
		let g:ctrlp_cache_dir = $HOME.'/.vim/cache/ctrlp'
		let g:ctrlp_map = '<c-p>'
		let g:ctrlp_cmd = 'CtrlPMixed'
		let g:ctrlp_show_hidden = 1
		let g:ctrlp_extensions = ['funky', 'modified']
	"}

	" csapprox {
		"dont load csapprox if we no gui support - silences an annoying warning
		if !has("gui")
			let g:CSApprox_loaded = 1
		endif
	"}

	" Ultisnips {
		" Use tab for Ultisnips
		let g:UltiSnipsExpandTrigger="<tab>"
	"}

	" neocomplete {
		if ( has('lua') && (v:version > 703 || v:version == 703 && has('patch885')) )
			" Disable AutoComplPop.
			let g:acp_enableAtStartup = 0
			" Use neocomplete.
			let g:neocomplete#enable_at_startup = 1
			" Use smartcase.
			let g:neocomplete#enable_smart_case = 1
			" Set minimum syntax keyword length.
			let g:neocomplete#sources#syntax#min_keyword_length = 3
			let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'
			let g:neocomplete#enable_insert_char_pre = 1
			let g:neocomplete#enable_auto_select = 1

			" Enable omni completion.
			autocmd Filetype css setlocal omnifunc=csscomplete#CompleteCSS
			autocmd Filetype html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
			autocmd Filetype javascript setlocal omnifunc=javascriptcomplete#CompleteJS
			autocmd Filetype python setlocal omnifunc=pythoncomplete#Complete
			autocmd Filetype xml setlocal omnifunc=xmlcomplete#CompleteTags

			" Enable heavy omni completion.
			if !exists('g:neocomplete#sources#omni#input_patterns')
				let g:neocomplete#sources#omni#input_patterns = {}
			endif
		endif
	"}

	" nerdtree {
		let g:NERDTreeMouseMode = 2
		let g:NERDTreeWinSize = 40
		let g:NERDTreeShowHidden=1
		let g:NERDTreeKeepTreeInNewTab=1
		let g:NERDTreeShowBookmarks=1
	"}

	" fugitive {
		"http://vimcasts.org/episodes/fugitive-vim-browsing-the-git-object-database/
		"hacks from above (the url, not jesus) to delete fugitive buffers when we
		"leave them - otherwise the buffer list gets poluted
		"add a mapping on .. to view parent tree
		autocmd BufReadPost fugitive://* set bufhidden=delete
		autocmd BufReadPost fugitive://*
			\ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
			\   nnoremap <buffer> .. :edit %:h<CR> |
			\ endif
	"}

	" airline {
		let g:airline#extensions#tabline#enabled = 1
		let g:airline#extensions#tabline#show_buffers = 0
		let g:airline_powerline_fonts = 1
		let g:airline_theme="powerlineish"
	"}

	" solarized {
		let g:solarized_termcolors=256
		set background=dark
		colorscheme solarized
	"}

	" PIV {
		let g:DisableAutoPHPFolding=1
	"}
	"
	" Tagbar {
		let g:tagbar_singleclick = 1
		let g:tagbar_sort = 0
	"}

"}

" Functions {
	function! DiffWithSaved()
		let filetype=&ft
		diffthis
		vnew | r # | normal! 1Gdd
		diffthis
		execute "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
	endfunction

	function! CmdLine(str)
		exe "menu Foo.Bar :" . a:str
		emenu Foo.Bar
		unmenu Foo
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

	" Delete trailing white space on save, useful for Python and CoffeeScript ;)
	func! DeleteTrailingWS()
		exe "normal mz"
		%s/\s\+$//ge
		exe "normal `z"
	endfunc
	autocmd BufWrite *.py :call DeleteTrailingWS()
	autocmd BufWrite *.coffee :call DeleteTrailingWS()

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
"}
