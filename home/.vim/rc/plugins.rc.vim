"---------------------------------------------------------------------------
" Plugin:
"

let g:inet_connection = system("ping -q -c 2 -W 1 google.com 2>&1 >/dev/null; echo ${?}")

if has('lua') && (v:version > 703 || (v:version == 703 && has('patch885')))
	if neobundle#tap('neocomplete.vim') "{{{
		NeoBundleSource neocomplete.vim
		let neobundle#hooks.on_source = '~/.vim/rc/plugins/neocomplete.rc.vim'
		call neobundle#untap()
	endif "}}}
else
	if neobundle#tap('neocomplcache.vim') "{{{
		NeoBundleSource neocomplcache.vim
		let neobundle#hooks.on_source = '~/.vim/rc/plugins/neocomplcache.rc.vim'
		call neobundle#untap()
	endif "}}}
endif

if neobundle#tap('neosnippet.vim') "{{{
	let neobundle#hooks.on_source = '~/.vim/rc/plugins/neosnippet.rc.vim'
	call neobundle#untap()
endif "}}}

if neobundle#tap('vimshell.vim') && neobundle#is_sourced('vimshell.vim') "{{{
	let neobundle#hooks.on_source = '~/.vim/rc/plugins/vimshell.rc.vim'
	call neobundle#untap()
endif "}}}

if neobundle#tap('unite.vim') && neobundle#is_sourced('unite.vim') "{{{
	let neobundle#hooks.on_source = '~/.vim/rc/plugins/unite.rc.vim'
	call neobundle#untap()
endif "}}}

if neobundle#tap('vimfiler.vim') && neobundle#is_sourced('vimfiler.vim') "{{{
	let neobundle#hooks.on_source = '~/.vim/rc/plugins/vimfiler.rc.vim'
endif "}}}

if neobundle#tap('quickrun.vim') && neobundle#is_sourced('quickrun.vim') "{{{
	nmap <silent> <Leader>r <Plug>(quickrun)
endif "}}}

if neobundle#tap('python.vim') && neobundle#is_sourced('python.vim') "{{{
	let python_highlight_all = 1
endif "}}}

if neobundle#tap('vim-ref') "{{{
	function! neobundle#hooks.on_source(bundle)
		let g:ref_cache_dir = expand('$CACHE/ref')
		let g:ref_use_vimproc = 1
		if IsWindows()
			let g:ref_refe_encoding = 'cp932'
		endif
		" ref-lynx.
		if IsWindows()
			let lynx = 'C:/lynx/lynx.exe'
			let cfg  = 'C:/lynx/lynx.cfg'
			let g:ref_lynx_cmd = s:lynx.' -cfg='.s:cfg.' -dump -nonumbers %s'
			let g:ref_alc_cmd = s:lynx.' -cfg='.s:cfg.' -dump %s'
		endif
		let g:ref_lynx_use_cache = 1
		let g:ref_lynx_start_linenumber = 0 " Skip.
		let g:ref_lynx_hide_url_number = 0
		autocmd MyAutoCmd FileType ref call s:ref_my_settings()
		function! s:ref_my_settings() "{{{
			" Overwrite settings.
			nmap <buffer> [Tag]t	<Plug>(ref-keyword)
			nmap <buffer> [Tag]p	<Plug>(ref-back)
		endfunction"}}}
	endfunction
endif"}}}

if neobundle#tap('vim-surround') "{{{
	nmap <silent>sa <Plug>(operator-surround-append)
	nmap <silent>sd <Plug>(operator-surround-delete)
	nmap <silent>sr <Plug>(operator-surround-replace)
	call neobundle#untap()
endif "}}}

" Operator-replace.
nmap R <Plug>(operator-replace)
xmap R <Plug>(operator-replace)
xmap p <Plug>(operator-replace)

if neobundle#tap('tagbar') && neobundle#is_sourced('tagbar') "{{{
	let g:tagbar_singleclick = 1
	let g:tagbar_sort = 0
	nnoremap <silent> <F3> :<C-u>TagbarToggle<CR>
	:imap <silent> <F3> <C-o>:<C-u>TagbarToggle<CR>
	call neobundle#untap()
endif "}}}

if neobundle#tap('undotree') && neobundle#is_sourced('undotree') "{{{
	let neobundle#hooks.on_source = '~/.vim/rc/plugins/undotree.rc.vim'
	call neobundle#untap()
endif "}}}

if neobundle#tap('vim-niceblock') "{{{
	xmap I <Plug>(niceblock-I)
	xmap A <Plug>(niceblock-A)
	call neobundle#untap()
endif "}}}

if neobundle#tap('matchit.zip') "{{{
	function! neobundle#hooks.on_post_source(bundle)
		silent! execute 'doautocmd Filetype' &filetype
	endfunction
	call neobundle#untap()
endif "}}}

if neobundle#tap('vim-fugitive') "{{{
	autocmd BufReadPost fugitive://* set bufhidden=delete
	autocmd BufReadPost fugitive://*
				\ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
				\   nnoremap <buffer> .. :edit %:h<CR> |
				\ endif
	call neobundle#untap()
endif "}}}

if neobundle#tap('vim-airline') "{{{
	let g:airline#extensions#tabline#enabled = 1
	let g:airline#extensions#tabline#show_buffers = 0
	let g:airline_powerline_fonts = 1
	let g:airline_theme="powerlineish"
	call neobundle#untap()
endif "}}}

if neobundle#tap('vim-colors-solarized') "{{{
	let g:solarized_termcolors=256
	let g:solarized_termtrans=0
	set background=dark
	colorscheme solarized
	call neobundle#untap()
endif "}}}

if neobundle#tap('PIV') "{{{
	let g:DisableAutoPHPFolding=1
	call neobundle#untap()
endif "}}}

if neobundle#tap('vim-easytags') "{{{
	let g:easytags_dynamic_files = 1
	let g:easytags_auto_highlight = 0
	let g:easytags_updatetime_warn = 0
	call neobundle#untap()
endif "}}}

if neobundle#tap('auto-neobundle') && g:inet_connection == 0 "{{{
	NeoBundleSource auto_neobundle
	augroup AutoNeoBundle
		autocmd!
		autocmd VimEnter * call auto_neobundle#update_daily()
	augroup END
	call neobundle#untap()
endif "}}}

if neobundle#tap('vim-diffchanges') && neobundle#is_sourced('vim-diffchanges') "{{{
	nnoremap <silent> <F12> :DiffChangesDiffToggle<CR>
	call neobundle#untap()
endif "}}}

if neobundle#tap('vim-trailing-whitespace') && neobundle#is_sourced('vim-trailing-whitespace') "{{{
	let g:extra_whitespace_ignored_filetypes = ['unite', 'vimfiler', 'vimfiler:explorer', 'startify']
endif "}}}

if neobundle#tap('vinarise.vim') && neobundle#is_sourced('vinarise.vim') "{{{
	let g:vinarise_enable_auto_detect = 1
endif "}}}

if neobundle#tap('promptline.vim') && neobundle#is_sourced('promptline.vim') "{{{
	let g:promptline_theme = 'powerlineclone'
	let g:promptline_preset = {
		\'a' : [ promptline#slices#user(), promptline#slices#host() ],
		\'b' : [ promptline#slices#vcs_branch({'git': 1, 'hg': 1, 'svn': 1}), promptline#slices#git_status() ],
		\'c' : [ promptline#slices#python_virtualenv() ],
		\'y' : [ promptline#slices#cwd() ],
		\'warn' : [ promptline#slices#last_exit_code() ]}
endif "}}}

if neobundle#tap('vim-startify') && neobundle#is_sourced('vim-startify') "{{{
	let neobundle#hooks.on_source = '~/.vim/rc/plugins/vim-startify.vim'
endif "}}}
