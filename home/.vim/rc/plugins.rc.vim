"---------------------------------------------------------------------------
" Plugin:
"

if neobundle#tap('neocomplete.vim') "{{{
	let g:neocomplete#enable_at_startup = 1
	let neobundle#hooks.on_source =
				\ '~/.vim/rc/plugins/neocomplete.rc.vim'
	call neobundle#untap()
endif "}}}

if neobundle#tap('neosnippet.vim') "{{{
	let neobundle#hooks.on_source =
				\ '~/.vim/rc/plugins/neosnippet.rc.vim'
	call neobundle#untap()
endif "}}}

if neobundle#tap('vimshell.vim') "{{{
	" <C-Space>: switch to vimshell.
	nmap <C-@>  <Plug>(vimshell_switch)
	nnoremap !  q:VimShellExecute<Space>
	nnoremap [Space]i  q:VimShellInteractive<Space>
	nnoremap [Space]t  q:VimShellTerminal<Space>
	let neobundle#hooks.on_source =
				\ '~/.vim/rc/plugins/vimshell.rc.vim'
	call neobundle#untap()
endif "}}}

if neobundle#tap('unite.vim') "{{{
	" The prefix key.
	nnoremap	  [unite]	<Nop>
	xnoremap	  [unite]	<Nop>
	nmap	  ;u [unite]
	xmap	  ;u [unite]
	nnoremap <silent> <F4> :Unite buffer -toggle -immediately<CR>
	imap <F4> <C-o>:Unite buffer -toggle -immediately<CR>
	nnoremap <C-P> :<C-u>Unite -buffer-name=files -start-insert buffer file_rec/async:!<cr>
	imap <C-p> <C-o>:<C-u>Unite -buffer-name=files -start-insert buffer file_rec/async:!<cr>
	nnoremap <expr><silent> ;b  <SID>unite_build()
	function! s:unite_build()
		return ":\<C-u>Unite -buffer-name=build". tabpagenr() ." -no-quit build\<CR>"
	endfunction
	nnoremap <silent> ;o
				\ :<C-u>Unite outline -start-insert -resume<CR>
	nnoremap <silent> ;t
				\ :<C-u>UniteWithCursorWord -buffer-name=tag tag tag/include<CR>
	xnoremap <silent> ;r
				\ d:<C-u>Unite -buffer-name=register register history/yank<CR>
	nnoremap <silent> <C-k>
				\ :<C-u>Unite change jump<CR>
	nnoremap <silent><expr> <C-f>
				\ ":\<C-u>Unite grep -buffer-name=grep%".tabpagenr()." -auto-preview -no-split -no-empty\<CR>"
	nnoremap <silent> ;r
				\ :<C-u>Unite -buffer-name=register register history/yank<CR>
	" <C-t>: Tab pages
	nnoremap <silent><expr> <C-t>
				\ ":\<C-u>Unite -auto-resize -select=".(tabpagenr()-1)." tab\<CR>"
	nnoremap <silent> [Window]s
				\ :<C-u>Unite -buffer-name=files -no-split -multi-line -unique -silent
				\ jump_point file_point buffer_tab:- file_mru
				\ file_rec/git file file/new<CR>
	nnoremap <expr><silent> [Window]r  ":\<C-u>Unite -start-insert ref/".ref#detect()."\<CR>"
	nnoremap <silent> [Window]<Space>  :<C-u>Unite -buffer-name=files file_rec:~/.vim/rc<CR>
	nnoremap <silent> [Window]n  :<C-u>Unite -default-action=lcd neobundle:!<CR>
	nnoremap <silent> [Window]f
				\ :<C-u>Unite <CR>
	nnoremap <silent> [Window]w
				\ :<C-u>Unite window<CR>
	nnoremap <silent> [Space]b
				\ :<C-u>UniteBookmarkAdd<CR>
	" t: tags-and-searches "{{{
	" The prefix key.
	nnoremap	  [Tag]   <Nop>
	nmap	  t [Tag]
	" Jump.
	" nnoremap [Tag]t  g<C-]>
	nnoremap <silent><expr> [Tag]t  &filetype == 'help' ?  "g\<C-]>" :
				\ ":\<C-u>UniteWithCursorWord -buffer-name=tag -immediately tag tag/include\<CR>"
	nnoremap <silent><expr> [Tag]p  &filetype == 'help' ?
				\ ":\<C-u>pop\<CR>" : ":\<C-u>Unite jump\<CR>"
	"}}}
	" Execute help.
	nnoremap <silent> <C-h>  :<C-u>Unite -buffer-name=help help<CR>
	" Execute help by cursor keyword.
	nnoremap <silent> g<C-h>	:<C-u>UniteWithCursorWord help<CR>
	" Search.
	nnoremap <silent><expr> /
				\ ":\<C-u>Unite -buffer-name=search%".bufnr('%')." -start-insert line:forward:wrap\<CR>"
	nnoremap <expr> g/  <SID>smart_search_expr('g/',
				\ ":\<C-u>Unite -buffer-name=search -start-insert line_migemo\<CR>")
	nnoremap <silent><expr> ?
				\ ":\<C-u>Unite -buffer-name=search%".bufnr('%')." -start-insert line:backward\<CR>"
	nnoremap <silent><expr> *
				\ ":\<C-u>UniteWithCursorWord -buffer-name=search%".bufnr('%')." line:forward:wrap\<CR>"
	nnoremap [Alt]/		/
	nnoremap [Alt]?		?
	cnoremap <expr><silent><C-g>		  (getcmdtype() == '/') ?
				\ "\<ESC>:Unite -buffer-name=search line:forward:wrap -input=".getcmdline()."\<CR>" : "\<C-g>"
	function! s:smart_search_expr(expr1, expr2)
		return line('$') > 5000 ?  a:expr1 : a:expr2
	endfunction
	nnoremap <silent><expr> n
				\ ":\<C-u>UniteResume search%".bufnr('%')." -no-start-insert\<CR>"
	nnoremap <silent> <C-w>  :<C-u>Unite -auto-resize window/gui<CR>
	let neobundle#hooks.on_source =
				\ '~/.vim/rc/plugins/unite.rc.vim'
	call neobundle#untap()
endif "}}}

" quickrun.vim"{{{
nmap <silent> <Leader>r <Plug>(quickrun)
"}}}

" python.vim
let python_highlight_all = 1

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

if neobundle#tap('nerdtree') "{{{
	let g:NERDTreeMouseMode = 2
	let g:NERDTreeWinSize = 40
	let g:NERDTreeShowHidden=1
	let g:NERDTreeKeepTreeInNewTab=1
	let g:NERDTreeShowBookmarks=1
	nnoremap <silent> <F2> :NERDTreeToggle<CR>
	:imap <F2> <C-o>:NERDTreeToggle<CR>
	nnoremap <silent> <C-F2> :NERDTreeFind<CR>
	:imap <C-F2> <C-o>:NERDTreeFind<CR>
	call neobundle#untap()
endif "}}}

if neobundle#tap('tagbar') "{{{
	let g:tagbar_singleclick = 1
	let g:tagbar_sort = 0
	nnoremap <silent> <F3> :TagbarToggle<CR>
	:imap <F3> <C-o>:TagbarToggle<CR>
	call neobundle#untap()
endif "}}}

if neobundle#tap('gundo.vim') "{{{
	nnoremap <silent> <F5> :GundoToggle<CR>
	:imap <F5> <C-o>:GundoToggle<CR>
	call neobundle#untap()
endif "}}}

if neobundle#tap('vim-niceblock') "{{{
	xmap I <Plug>(niceblock-I)
	xmap A <Plug>(niceblock-A)
	call neobundle#untap()
endif "}}}

if neobundle#tap('vim-smalls') "{{{
	nmap S <Plug>(smalls)
	call neobundle#untap()
endif "}}}

if neobundle#tap('vim-vcs') "{{{
	nnoremap <silent> [Space]gs  :<C-u>Vcs status<CR>
	nnoremap <silent> [Space]gc  :<C-u>Vcs commit<CR>
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

if neobundle#tap('auto-neobundle') "{{{
	let g:auto_neobundle_timestamp_dir = "~/.vim/cache"
	augroup AutoNeoBundle
		autocmd!
		autocmd VimEnter * call auto_neobundle#update_daily()
	augroup END
	call neobundle#untap()
endif "}}}
