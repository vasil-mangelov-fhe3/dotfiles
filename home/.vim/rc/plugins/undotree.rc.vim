"=================================================
"Options:
nnoremap <silent> <F5> :UndotreeToggle<CR>
:imap <F5> <C-o>:UndotreeToggle<CR>
" Window layout
" style 1
" +----------+------------------------+
" |          |                        |
" |          |                        |
" | undotree |                        |
" |          |                        |
" |          |                        |
" +----------+                        |
" |          |                        |
" |   diff   |                        |
" |          |                        |
" +----------+------------------------+
" Style 2
" +----------+------------------------+
" |          |                        |
" |          |                        |
" | undotree |                        |
" |          |                        |
" |          |                        |
" +----------+------------------------+
" |                                   |
" |   diff                            |
" |                                   |
" +-----------------------------------+
" Style 3
" +------------------------+----------+
" |                        |          |
" |                        |          |
" |                        | undotree |
" |                        |          |
" |                        |          |
" |                        +----------+
" |                        |          |
" |                        |   diff   |
" |                        |          |
" +------------------------+----------+
" Style 4
" +-----------------------++----------+
" |                        |          |
" |                        |          |
" |                        | undotree |
" |                        |          |
" |                        |          |
" +------------------------+----------+
" |                                   |
" |                            diff   |
" |                                   |
" +-----------------------------------+
if !exists('g:undotree_WindowLayout')
	let g:undotree_WindowLayout = 1
endif

" undotree window width
if !exists('g:undotree_SplitWidth')
	let g:undotree_SplitWidth = 60
endif

" diff window height
if !exists('g:undotree_DiffpanelHeight')
	let g:undotree_DiffpanelHeight = 20
endif

" auto open diff window
if !exists('g:undotree_DiffAutoOpen')
	let g:undotree_DiffAutoOpen = 1
endif

" if set, let undotree window get focus after being opened, otherwise
" focus will stay in current window.
if !exists('g:undotree_SetFocusWhenToggle')
	let g:undotree_SetFocusWhenToggle = 1
endif

" tree node shape.
if !exists('g:undotree_TreeNodeShape')
	let g:undotree_TreeNodeShape = '*'
endif

if !exists('g:undotree_DiffCommand')
	let g:undotree_DiffCommand = "diff"
endif

" relative timestamp
if !exists('g:undotree_RelativeTimestamp')
	let g:undotree_RelativeTimestamp = 1
endif

" Highlight changed text
if !exists('g:undotree_HighlightChangedText')
	let g:undotree_HighlightChangedText = 1
endif

" Highlight linked syntax type.
" You may chose your favorite through ":hi" command
if !exists('g:undotree_HighlightSyntaxAdd')
	let g:undotree_HighlightSyntaxAdd = "DiffAdd"
endif

if !exists('g:undotree_HighlightSyntaxChange')
	let g:undotree_HighlightSyntaxChange = "DiffChange"
endif
"Custom key mappings: add this function to your vimrc.
"You can define whatever mapping as you like, this is a hook function which
"will be called after undotree window initialized.
"
"function g:undotree_CustomMap()
"    map <buffer> <c-n> J
"    map <buffer> <c-p> K
"endfunction

"=================================================
function g:Undotree_CustomMap()
	map <buffer> OA K
	map <buffer> OB J
endfunction

