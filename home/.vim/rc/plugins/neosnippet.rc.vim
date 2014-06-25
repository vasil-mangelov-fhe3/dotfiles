"---------------------------------------------------------------------------
" neosnippet.vim
"

" Plugin key-mappings.
imap <silent><C-e>     <Plug>(neosnippet_jump_or_expand)
smap <silent><C-e>     <Plug>(neosnippet_jump_or_expand)
xmap <silent><C-e>     <Plug>(neosnippet_start_unite_snippet_target)

" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif

let g:neosnippet#enable_snipmate_compatibility = 1

let g:snippets_dir = '~/.vim/snippets/,~/.vim/bundle/snipmate/snippets/'
let g:neosnippet#snippets_directory = '~/.vim/snippets'
