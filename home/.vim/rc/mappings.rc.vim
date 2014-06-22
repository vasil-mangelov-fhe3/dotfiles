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
command! -bang Q quit<bang>
map <F1> <Nop>
autocmd VimEnter * if exists(":NERDTreeToggle") | execute "nnoremap <silent> <F2> :NERDTreeToggle\<CR>" | execute ":imap <F2> <C-o>:NERDTreeToggle\<CR>" | endif
autocmd VimEnter * if exists(":NERDTreeFindToggle") | execute "nnoremap <silent> <C-F2> :NERDTreeFind\<CR>" | execute ":imap <C-F2> <C-o>:NERDTreeFind\<CR>" | endif
autocmd VimEnter * if exists(":TagbarToggle") | execute "nnoremap <silent> <F3> :TagbarToggle\<CR>" | execute ":imap <F3> <C-o>:TagbarToggle\<CR>" | endif
autocmd VimEnter * if exists(":GundoToggle") | execute "nnoremap <silent> <F5> :GundoToggle\<CR>" | execute ":imap <F5> <C-o>:GundoToggle\<CR>" | endif
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
