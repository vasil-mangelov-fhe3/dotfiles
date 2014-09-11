NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'gregsexton/MatchTag'
NeoBundle 'vim-scripts/delimitMate.vim'
NeoBundle 'tpope/vim-endwise'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-git'
NeoBundle 'sjl/gundo.vim', {
			\ 'disabled' : !has('python'),
			\ 'vim_version' : '7.3'
			\ }
NeoBundle 'Yggdroot/indentLine'
NeoBundle 'vim-scripts/IndexedSearch'
NeoBundle 'tpope/vim-markdown'
NeoBundle 'scrooloose/nerdcommenter'
NeoBundle 'shawncplus/phpcomplete.vim'
NeoBundle 'spf13/PIV'
NeoBundle 'tpope/vim-ragtag'
NeoBundle 'hail2u/vim-css3-syntax', {
			\ 'autoload' : { 'filetypes' : 'syntax'}
			\ }
NeoBundle 'medihack/sh.vim', {
			\ 'autoload' : { 'filetypes' : 'syntax'}
			\ }
NeoBundle 'altercation/vim-colors-solarized', {
			\ 'autoload' : { 'unite_sources' : 'colorscheme', }
			\ }
NeoBundle 'tpope/vim-surround'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'godlygeek/tabular'
NeoBundle 'majutsushi/tagbar'
NeoBundle 'tpope/vim-unimpaired'
NeoBundle 'bling/vim-airline'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'jrhorn424/vim-multiple-cursors'
NeoBundle 'sheerun/vim-polyglot'
NeoBundle 'tpope/vim-rails'
NeoBundle 'mtscout6/vim-tagbar-css'
NeoBundle 'bronson/vim-trailing-whitespace'
NeoBundle 'ujihisa/vimshell-ssh', {
			\ 'filetypes' : 'vimshell',
			\ }
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
NeoBundle 'yomi322/vim-gitcomplete', {
			\ 'filetype' : 'vimshell'
			\ }
NeoBundle 'kana/vim-niceblock'
NeoBundle 'thinca/vim-quickrun', {
			\ 'commands' : 'QuickRun',
			\ 'mappings' : [
			\   ['nxo', '<Plug>(quickrun)']],
			\ }
NeoBundle 'Shougo/unite.vim', {
			\ 'commands' : [{ 'name' : 'Unite',
			\ 'complete' : 'customlist,unite#complete_source'},
			\ 'UniteWithCursorWord', 'UniteWithInput']
			\ }
NeoBundle 'Shougo/neomru.vim', {'autoload':{'unite_sources':
			\ ['file_mru', 'directory_mru']}}
NeoBundle 'Shougo/unite-build'
NeoBundle 'Shougo/vinarise.vim'
NeoBundle 'majkinetor/unite-cmdmatch'
NeoBundle 'Shougo/unite-sudo'
NeoBundle 'thinca/vim-ref', {
			\ 'commands' : 'Ref',
			\ 'unite_sources' : 'ref',
			\ }
NeoBundle 'thinca/vim-unite-history', {
			\ 'unite_sources' : ['history/command', 'history/search']
			\ }
NeoBundle 'Shougo/unite-outline', {'autoload':{'unite_sources':'outline'}}
NeoBundle 'Shougo/unite-help', {'autoload':{'unite_sources':'help'}}
NeoBundle 'ujihisa/unite-locate', {'autoload':{'unite_sources':'locate'}}
NeoBundle 'tsukkee/unite-tag', {
			\ 'unite_sources' : ['tag', 'tag/include', 'tag/file']
			\ }
NeoBundle 'Shougo/unite-session'
NeoBundle 'kopischke/unite-spell-suggest'
NeoBundle 'osyo-manga/unite-filetype'
NeoBundle 'kana/vim-tabpagecd', {
			\ 'unite_sources' : 'tab'
			\ }
NeoBundle 'supermomonga/unite-kawaii-calc'
NeoBundle 'godlygeek/csapprox', { 'terminal' : 1 }
NeoBundle 'ujihisa/neco-look'
NeoBundle 'tpope/vim-repeat', {
			\ 'mappings' : '.',
			\ }
NeoBundle 'matchit.zip', {
			\ 'mappings' : [['nxo', '%', 'g%']]
			\ }
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
NeoBundle 'kana/vim-operator-user', {
			\  'functions' : 'operator#user#define',
			\}
NeoBundle 'tejr/vim-tmux', {
			\ 'autoload' : {
			\ 'filetypes' : 'conf'}}
NeoBundle 'xolox/vim-easytags', {
			\ 'external_commands' : 'ctags-exuberant',
			\ 'depends' : 'xolox/vim-misc'
			\ }
NeoBundle 'pbrisbin/vim-mkdir'
NeoBundle 'jmcantrell/vim-diffchanges'
NeoBundleLazy 'NemesisRE/auto-neobundle'
