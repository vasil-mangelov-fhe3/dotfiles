"---------------------------------------------------------------------------
" Key-mappings:
"

" Use <C-Space>.
nmap <C-Space>  <C-@>
cmap <C-Space>  <C-@>

" Visual mode keymappings: "{{{
" <TAB>: indent.
xnoremap <TAB>  >
" <S-TAB>: unindent.
xnoremap <S-TAB>  <

" Indent
nnoremap > >>
nnoremap < <<
xnoremap > >gv
xnoremap < <gv

" make :Q work like :q
command! -bang QQ :call SmartExit()<bang>
command! -bang Q q<bang>
command! -bang W w<bang>
command! -bang Wq wq<bang>
command! -bang WQ wq<bang>
nnoremap <silent> <F6> :call CopyModeToggle()<CR>
:inoremap <F6> <C-o>:<C-u>call CopyModeToggle()<CR>
nnoremap <silent> <F11> :setlocal spell! spell?<CR>
:inoremap <F11> <C-o>:<C-u>setlocal spell! spell?<CR>
" Next Tab
nnoremap <silent> <C-Right> :tabnext<CR>
" Previous Tab
nnoremap <silent> <C-Left> :tabprevious<CR>
"make <c-l> clear the highlight as well as redraw
nnoremap <C-L> :nohls<CR><C-L>
inoremap <C-L> <C-O>:nohls<CR>

if has('clipboard')
	xnoremap <silent> y "*y:let [@+,@"]=[@*,@*]<CR>
endif
"}}}

if has('gui_running')
	inoremap <ESC> <ESC>
endif

" Command-line mode keymappings:"{{{
" <C-a>, A: move to head.
cnoremap <C-a>          <Home>
" <C-b>: previous char.
cnoremap <C-b>          <Left>
" <C-d>: delete char.
cnoremap <C-d>          <Del>
" <C-e>, E: move to end.
cnoremap <C-e>          <End>
" <C-f>: next char.
cnoremap <C-f>          <Right>
" <C-n>: next history.
cnoremap <C-n>          <Down>
" <C-p>: previous history.
cnoremap <C-p>          <Up>
" <C-k>, K: delete to end.
cnoremap <C-k> <C-\>e getcmdpos() == 1 ?
			\ '' : getcmdline()[:getcmdpos()-2]<CR>
" <C-y>: paste.
cnoremap <C-y>          <C-r>*

cmap <C-o>          <Plug>(unite_cmdmatch_complete)
"}}}

" Command line buffer."{{{
nnoremap <SID>(command-line-enter) q:
xnoremap <SID>(command-line-enter) q:
nnoremap <SID>(command-line-norange) q:<C-u>

nmap ;;  <SID>(command-line-enter)
xmap ;;  <SID>(command-line-enter)

autocmd MyAutoCmd CmdwinEnter * call s:init_cmdwin()
autocmd MyAutoCmd CmdwinLeave * let g:neocomplcache_enable_auto_select = 1

function! s:init_cmdwin()
	let g:neocomplcache_enable_auto_select = 0
	let b:neocomplcache_sources_list = ['vim_complete']

	nnoremap <buffer><silent> q :<C-u>quit<CR>
	nnoremap <buffer><silent> <TAB> :<C-u>quit<CR>
	inoremap <buffer><expr><CR> neocomplete#close_popup()."\<CR>"
	inoremap <buffer><expr><C-h> col('.') == 1 ?
				\ "\<ESC>:quit\<CR>" : neocomplete#cancel_popup()."\<C-h>"
	inoremap <buffer><expr><BS> col('.') == 1 ?
				\ "\<ESC>:quit\<CR>" : neocomplete#cancel_popup()."\<C-h>"

	" Completion.
	inoremap <buffer><expr><TAB>  pumvisible() ?
				\ "\<C-n>" : <SID>check_back_space() ? "\<TAB>" : "\<C-x>\<C-u>\<C-p>"

	" Remove history lines.
	silent execute printf("1,%ddelete _", min([&history - 20, line("$") - 20]))
	call cursor(line('$'), 0)

	startinsert!
endfunction"}}}
