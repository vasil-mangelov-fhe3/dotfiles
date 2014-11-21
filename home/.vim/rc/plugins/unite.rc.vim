"---------------------------------------------------------------------------
" unite.vim
"
" FIXME: insert mode after leaving unite

" The prefix key.
nnoremap	[unite] <Nop>
xnoremap	[unite] <Nop>
nmap	;u [unite]
xmap	;u [unite]
nnoremap <silent> <F1> :<C-u>Unite -profile-name=menu menu:Main<CR>
inoremap <silent> <F1> <C-o>:<C-u>Unite -profile-name=menu menu:Main<CR>
nnoremap <silent> <F4> :<C-u>Unite buffer_tab -toggle -start-insert<CR>
inoremap <silent> <F4> <C-o>:<C-u>Unite buffer_tab -toggle -start-insert<CR>
nnoremap <silent> <F9> :<C-u>Unite tasklist -toggle -start-insert -vertical -winwidth=40<CR>
inoremap <silent> <F9> <C-o>:<C-u>Unite tasklist -toggle -start-insert -vertical -winwidth=40<CR>
nnoremap <silent> <C-P> :<C-u>Unite -buffer-name=files -toggle -start-insert neomru/file file_rec/async:!<CR>
nnoremap <expr><silent> ;b  <SID>unite_build()
function! s:unite_build()
	return ":\<C-u>Unite -buffer-name=build". tabpagenr() ." -no-quit build\<CR>"
endfunction
nnoremap <silent> ;o :<C-u>Unite outline -start-insert -resume<CR>
nnoremap <silent> ;t :<C-u>UniteWithCursorWord -buffer-name=tag tag tag/include<CR>
nnoremap <silent> <C-k> :<C-u>Unite change jump<CR>
nnoremap <silent> <C-f> :<C-u>Unite grep:. -buffer-name=grep%".tabpagenr()." -toggle -auto-preview -no-split -no-empty<CR>
inoremap <silent> <F10> <C-o>:<C-u>Unite -buffer-name=register -toggle register history/yank<CR>
nnoremap <silent> <F10> :<C-u>Unite -buffer-name=register -toggle register history/yank<CR>
" <C-t>: Tab pages>
nnoremap <silent><expr> <C-t> :<C-u>Unite -auto-resize -select=".(tabpagenr()-1)." tab<CR>
nnoremap <silent> [Window]s :<C-u>Unite -buffer-name=files -no-split -multi-line -unique -silent
			\ jump_point file_point buffer_tab:- file_mru
			\ file_rec/git file file/new<CR>
nnoremap <expr><silent> [Window]r :\<C-u>Unite -start-insert ref/".ref#detect()."<CR>
nnoremap <silent> [Window]<Space> :<C-u>Unite -buffer-name=files file_rec:~/.vim/rc<CR>
nnoremap <silent> [Window]n :<C-u>Unite -default-action=lcd neobundle:!<CR>
nnoremap <silent> [Window]f :<C-u>Unite <CR>
nnoremap <silent> [Window]w :<C-u>Unite window<CR>
nnoremap <silent> [Space]b :<C-u>UniteBookmarkAdd<CR>
" t: tags-and-searches "{{{
" The prefix key.
nnoremap	[Tag] <Nop>
nmap	t [Tag]
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
nnoremap <silent><expr> / ":\<C-u>Unite -buffer-name=search line:all -start-insert -no-quit\<CR>"
nnoremap <expr> g/  <SID>smart_search_expr('g/',
			\ :<C-u>Unite -buffer-name=search -start-insert line_migemo<CR>)
nnoremap <silent><expr> ? ":\<C-u>Unite -buffer-name=search%".bufnr('%')." -start-insert line:backward\<CR>"
nnoremap <silent><expr> * ":\<C-u>UniteWithCursorWord -buffer-name=search%".bufnr('%')." line:forward:wrap\<CR>"
nnoremap [Alt]/ /
nnoremap [Alt]? ?
cnoremap <expr><silent><C-g> (getcmdtype() == '/') ?
			\ "\<ESC>:Unite -buffer-name=search line:forward:wrap -input=".getcmdline()."\<CR>" : "\<C-g>"
function! s:smart_search_expr(expr1, expr2)
	return line('$') > 5000 ?  a:expr1 : a:expr2
endfunction
" FIXME: Search next and previous doesnt work.
nnoremap <silent> n :<C-u>UniteNext search<CR>
nnoremap <silent> N :<C-u>UnitePrevious search<CR>
" Default configuration.
let default_context = {
			\ 'vertical' : 0,
			\ 'cursor_line_highlight' : 'TabLineSel',
			\ 'complete' : 1,
			\ }

let g:unite_enable_short_source_names = 1
" let g:unite_abbr_highlight = 'TabLine'

if IsWindows()
else
	" Like Textmate icons.
	let g:unite_marked_icon = '✗'
	let default_context.prompt = '» '
endif

call unite#custom#profile('default', 'context', default_context)

let g:unite_kind_file_vertical_preview = 1

let g:unite_split_rule = "botright"
let g:unite_force_overwrite_statusline = 0
let g:unite_source_history_yank_enable = 1

" For unite-alias.
let g:unite_source_alias_aliases = {}
let g:unite_source_alias_aliases.line_migemo = 'line'
let g:unite_source_alias_aliases.calc = 'kawaii-calc'
let g:unite_source_alias_aliases.l = 'launcher'
let g:unite_source_alias_aliases.kill = 'process'
let g:unite_source_alias_aliases.message = {
			\ 'source' : 'output',
			\ 'args'   : 'message',
			\ }
let g:unite_source_alias_aliases.mes = {
			\ 'source' : 'output',
			\ 'args'   : 'message',
			\ }
let g:unite_source_alias_aliases.scriptnames = {
			\ 'source' : 'output',
			\ 'args'   : 'scriptnames',
			\ }

autocmd MyAutoCmd FileType unite call s:unite_my_settings()

let g:unite_ignore_source_files = []

" migemo.
call unite#custom#source('line_migemo', 'matchers', 'matcher_migemo')

" Custom filters."{{{
call unite#custom#source(
			\ 'buffer,file_rec,file_rec/async,file_rec/git', 'matchers',
			\ ['converter_relative_word', 'matcher_fuzzy',
			\  'matcher_project_ignore_files'])
call unite#custom#source(
			\ 'file_mru', 'matchers',
			\ ['matcher_project_files', 'matcher_fuzzy'])
" call unite#custom#source(
"       \ 'file', 'matchers',
"       \ ['matcher_fuzzy', 'matcher_hide_hidden_files'])
call unite#custom#source(
			\ 'file_rec,file_rec/async,file_rec/git,file_mru', 'converters',
			\ ['converter_file_directory'])
call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_rank'])
"}}}

function! s:unite_my_settings() "{{{
	" Directory partial match.
	call unite#custom#alias('file', 'h', 'left')
	call unite#custom#default_action('directory', 'narrow')

	call unite#custom#default_action('versions/git/status', 'commit')

	" Overwrite settings.
	imap <silent><buffer><expr> <C-x> unite#do_action('split')
	nmap <silent><buffer><expr> <C-x> unite#do_action('split')
	imap <silent><buffer><expr> <C-v> unite#do_action('vsplit')
	nmap <silent><buffer><expr> <C-v> unite#do_action('vsplit')
	imap <silent><buffer><expr> <C-t> unite#do_action('tabopen')
	nmap <silent><buffer><expr> <C-t> unite#do_action('tabopen')
	imap <buffer>  jj        <Plug>(unite_insert_leave)
	imap <buffer>  <Tab>     <Plug>(unite_complete)
	imap <buffer> <C-w>      <Plug>(unite_delete_backward_path)
	imap <buffer> '          <Plug>(unite_quick_match_default_action)
	nmap <buffer> '          <Plug>(unite_quick_match_default_action)
	nmap <buffer> cd         <Plug>(unite_quick_match_default_action)
	nmap <buffer> <C-z>      <Plug>(unite_toggle_transpose_window)
	imap <buffer> <C-z>      <Plug>(unite_toggle_transpose_window)
	imap <buffer> <C-w>      <Plug>(unite_delete_backward_path)
	nmap <buffer> <C-j>      <Plug>(unite_toggle_auto_preview)
	nnoremap <silent><buffer> <Tab>     <C-w>w
	nnoremap <silent><buffer><expr> l
				\ unite#smart_map('l', unite#do_action('default'))
	nnoremap <silent> /  :<C-u>Unite -buffer-name=search
				\ line -start-insert -no-quit<CR>

	let unite = unite#get_current_unite()
	if unite.profile_name ==# '^search'
		nnoremap <silent><buffer><expr> r     unite#do_action('replace')
	else
		nnoremap <silent><buffer><expr> r     unite#do_action('rename')
	endif

	nnoremap <silent><buffer><expr> cd     unite#do_action('lcd')
	nnoremap <silent><buffer><expr> x     unite#do_action('start')
	nnoremap <buffer><expr> S      unite#mappings#set_current_filters(
				\ empty(unite#mappings#get_current_filters()) ? ['sorter_reverse'] : [])
endfunction"}}}

if executable('ag')
	" Use ag in unite grep source.
	let g:unite_source_grep_command = 'ag'
	let g:unite_source_grep_default_opts =
				\ '--line-numbers --nocolor --nogroup --hidden --ignore ' .
				\  '''.hg'' --ignore ''.svn'' --ignore ''.git'' --ignore ''.bzr'''
	let g:unite_source_grep_recursive_opt = ''
elseif executable('pt')
	let g:unite_source_grep_command = 'pt'
	let g:unite_source_grep_default_opts = '--nogroup --nocolor'
	let g:unite_source_grep_recursive_opt = ''
elseif executable('jvgrep')
	" For jvgrep.
	let g:unite_source_grep_command = 'jvgrep'
	let g:unite_source_grep_default_opts = '--exclude ''\.(git|svn|hg|bzr)'''
	let g:unite_source_grep_recursive_opt = '-R'
elseif executable('ack-grep')
	" For ack.
	let g:unite_source_grep_command = 'ack-grep'
	let g:unite_source_grep_default_opts = '--no-heading --no-color -a'
	let g:unite_source_grep_recursive_opt = ''
endif

let g:unite_build_error_icon    = '~/.vim/signs/err.'
			\ . (IsWindows() ? 'bmp' : 'png')
let g:unite_build_warning_icon  = '~/.vim/signs/warn.'
			\ . (IsWindows() ? 'bmp' : 'png')
let g:unite_source_rec_max_cache_files = -1
call unite#custom_source('file_rec,file_rec/async,file_mru,file,buffer,grep',
			\ 'ignore_pattern', join([
			\ '\.git/',
			\ ], '\|'))

" Source Menu
call g:Source_rc('plugins/unite.menu.vim')

