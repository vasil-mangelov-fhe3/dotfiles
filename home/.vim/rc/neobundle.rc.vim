NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundleLazy 'Shougo/neocomplcache.vim', {
			\ 'insert' : 1
			\ }
NeoBundleLazy 'Shougo/neocomplete.vim', {
			\ 'insert' : 1,
			\ 'depends' : 'Shougo/context_filetype.vim',
			\ 'disabled' : !has('lua'),
			\ 'vim_version' : '7.3.885'
			\ }
NeoBundle 'Shougo/neocomplcache-rsense', {
			\ 'depends' : 'Shougo/neocomplete.vim'
			\ }
NeoBundle 'Shougo/neosnippet.vim', {
			\ 'depends' : ['Shougo/neosnippet-snippets', 'Shougo/context_filetype.vim', 'honza/vim-snippets'],
			\ 'insert' : 1,
			\ 'filetypes' : 'snippet',
			\ 'unite_sources' : [
			\						'neosnippet', 'neosnippet/user', 'neosnippet/runtime'],
			\ }
NeoBundle 'Shougo/vimproc.vim', {
			\ 'build' : {
			\				'windows' : 'make -f make_mingw32.mak',
			\				'cygwin' : 'make -f make_cygwin.mak',
			\				'mac' : 'make -f make_mac.mak',
			\				'unix' : 'make -f make_unix.mak',
			\			}
			\ }
NeoBundle 'Shougo/vimshell.vim', {
			\ 'commands' : [	{
			\						'name' : 'VimShell',
			\						'complete' : 'customlist,vimshell#complete'
			\					},
			\					'VimShellExecute', 'VimShellInteractive',
			\					'VimShellCreate',
			\					'VimShellTerminal', 'VimShellPop'
			\				],
			\ 'mappings' : '<Plug>(vimshell_'
			\ }
NeoBundle 'Shougo/vimfiler.vim', {
			\ 'depends' : 'Shougo/unite.vim',
			\ 'commands' : [	{
			\						'name' : ['VimFiler', 'Edit', 'Write'],
			\						'complete' : 'customlist,vimfiler#complete'
			\					},
			\					'Read', 'Source'
			\				],
			\ 'mappings' : '<Plug>',
			\ 'explorer' : 1,
			\ }
NeoBundle 'Shougo/tabpagebuffer.vim'
NeoBundle 'Shougo/unite.vim', {
			\ 'commands' : [{ 'name' : 'Unite',
			\ 'complete' : 'customlist,unite#complete_source'},
			\ 'UniteWithCursorWord', 'UniteWithInput']
			\ }
NeoBundle 'Shougo/neomru.vim', {'autoload':{'unite_sources':
			\ ['file_mru', 'directory_mru']}}
NeoBundle 'Shougo/unite-build'
NeoBundle 'Shougo/vinarise.vim'
NeoBundle 'Shougo/unite-sudo'
NeoBundle 'Shougo/unite-outline', {'autoload':{'unite_sources':'outline'}}
NeoBundle 'Shougo/unite-help', {'autoload':{'unite_sources':'help'}}
NeoBundle 'Shougo/unite-session'
NeoBundle 'thinca/vim-ref', {
			\ 'commands' : 'Ref',
			\ 'unite_sources' : 'ref',
			\ }
NeoBundle 'thinca/vim-unite-history', {
			\ 'unite_sources' : ['history/command', 'history/search']
			\ }
NeoBundle 'thinca/vim-quickrun', {
			\ 'commands' : 'QuickRun',
			\ 'mappings' : [
			\   ['nxo', '<Plug>(quickrun)']],
			\ }
NeoBundle 'kana/vim-niceblock'
NeoBundle 'kana/vim-tabpagecd', {
			\ 'unite_sources' : 'tab'
			\ }
NeoBundle 'kana/vim-operator-user', {
			\  'functions' : 'operator#user#define',
			\}
NeoBundle 'ujihisa/vimshell-ssh', {
			\ 'filetypes' : 'vimshell',
			\ }
NeoBundle 'ujihisa/unite-locate', {'autoload':{'unite_sources':'locate'}}
NeoBundle 'ujihisa/neco-look'
NeoBundle 'tpope/vim-endwise'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-git'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-unimpaired'
NeoBundle 'tpope/vim-ragtag'
NeoBundle 'tpope/vim-repeat', {
			\ 'mappings' : '.',
			\ }
NeoBundle 'mbbill/undotree', {
			\ 'vim_version' : '7.3',
			\ }
NeoBundle 'Yggdroot/indentLine'
NeoBundle 'scrooloose/nerdcommenter'
NeoBundle 'altercation/vim-colors-solarized', {
			\ 'autoload' : { 'unite_sources' : 'colorscheme', }
			\ }
NeoBundle 'scrooloose/syntastic'
NeoBundle 'godlygeek/tabular'
NeoBundle 'junkblocker/unite-tasklist'
NeoBundle 'majutsushi/tagbar'
NeoBundle 'bling/vim-airline'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'jrhorn424/vim-multiple-cursors'
NeoBundle 'mtscout6/vim-tagbar-css'
NeoBundle 'bronson/vim-trailing-whitespace'
NeoBundle 'tsukkee/unite-tag', {
			\ 'unite_sources' : ['tag', 'tag/include', 'tag/file']
			\ }
NeoBundle 'yomi322/vim-gitcomplete', {
			\ 'filetype' : 'vimshell'
			\ }
NeoBundle 'kopischke/unite-spell-suggest'
NeoBundle 'osyo-manga/unite-filetype'
NeoBundle 'supermomonga/unite-kawaii-calc'
NeoBundle 'gregsexton/MatchTag'
NeoBundle 'vim-scripts/delimitMate.vim'
NeoBundle 'godlygeek/csapprox', { 'terminal' : 1 }
NeoBundle 'matchit.zip', {
			\ 'mappings' : [['nxo', '%', 'g%']]
			\ }
NeoBundle 'xolox/vim-easytags', {
			\ 'external_commands' : 'ctags-exuberant',
			\ 'depends' : 'xolox/vim-misc'
			\ }
NeoBundle 'pbrisbin/vim-mkdir'
NeoBundle 'jmcantrell/vim-diffchanges'
NeoBundleLazy 'NemesisRE/auto-neobundle'
NeoBundle 'editorconfig/editorconfig-vim'
NeoBundle 'zhaocai/DirDiff.vim'
NeoBundle 'edkolev/promptline.vim'
NeoBundle 'mhinz/vim-startify'
NeoBundle 'ap/vim-css-color'
NeoBundle 'bogado/file-line'
NeoBundle 'vim-scripts/bufkill.vim'

" Syntax
NeoBundle 'Shougo/javacomplete', {
				\ 'external_commands' : 'javac',
				\ 'build': {
				\       'cygwin': 'javac autoload/Reflection.java',
				\       'mac': 'javac autoload/Reflection.java',
				\       'unix': 'javac autoload/Reflection.java',
				\   },
				\ 'autoload' : {
				\   'filetypes' : 'java',
				\ }
				\}
NeoBundle 'tpope/vim-rails'
NeoBundle 'chrisbra/csv.vim'
NeoBundle 'rodjek/vim-puppet'
NeoBundle 'JulesWang/css.vim'
NeoBundle 'othree/html5.vim'
NeoBundle 'pangloss/vim-javascript'
NeoBundle 'phongnh/vim-jquery'
NeoBundle 'vim-perl/vim-perl'
NeoBundle 'evanmiller/nginx-vim-syntax'
NeoBundle 'StanAngeloff/php.vim'
NeoBundle 'vim-ruby/vim-ruby'
NeoBundle 'tejr/vim-tmux'
NeoBundle 'klen/python-mode'
NeoBundle 'plasticboy/vim-markdown'
NeoBundle 'shawncplus/phpcomplete.vim'
NeoBundle 'spf13/PIV'
NeoBundle 'medihack/sh.vim', {
			\ 'autoload' : { 'filetypes' : 'syntax'}
			\ }
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'elzr/vim-json'
NeoBundle 'vim-scripts/SQLComplete.vim'
NeoBundle 'violetyk/cake.vim', {
			\ 'vim_version' : '7.3.885',
			\ }

