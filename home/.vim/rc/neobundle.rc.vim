NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'gregsexton/MatchTag'
NeoBundle 'vim-scripts/delimitMate.vim'
NeoBundle 'tpope/vim-endwise'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-git'
NeoBundle 'sjl/gundo.vim'
NeoBundle 'Yggdroot/indentLine'
NeoBundle 'vim-scripts/IndexedSearch'
NeoBundle 'tpope/vim-markdown'
NeoBundle 'scrooloose/nerdcommenter'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'jistr/vim-nerdtree-tabs'
NeoBundle 'shawncplus/phpcomplete.vim'
NeoBundle 'spf13/PIV'
NeoBundle 'tpope/vim-ragtag'
NeoBundle 'medihack/sh.vim'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'tpope/vim-surround'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'godlygeek/tabular'
NeoBundle 'majutsushi/tagbar'
NeoBundle 'tpope/vim-unimpaired'
NeoBundle 'bling/vim-airline'
NeoBundle 'Lokaltog/vim-easymotion'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'jrhorn424/vim-multiple-cursors'
NeoBundle 'sheerun/vim-polyglot'
NeoBundle 'tpope/vim-rails'
NeoBundle 'mtscout6/vim-tagbar-css'
NeoBundle 'bronson/vim-trailing-whitespace'
NeoBundle 'Shougo/unite.vim', {
			\ 'commands' : [{ 'name' : 'Unite',
			\ 'complete' : 'customlist,unite#complete_source'},
			\ 'UniteWithCursorWord', 'UniteWithInput']
			\ }
NeoBundle 'Shougo/unite-build'
NeoBundle 'Shougo/neomru.vim'
NeoBundle 'ujihisa/vimshell-ssh', {
			\ 'filetypes' : 'vimshell',
			\ }
NeoBundle 'Shougo/unite-sudo'
NeoBundle 'Shougo/neocomplete.vim', {
			\ 'depends' : 'Shougo/context_filetype.vim',
			\ 'insert' : 1
			\ }
NeoBundle 'Shougo/neocomplcache-rsense'
NeoBundle 'Shougo/neosnippet.vim', {
			\ 'depends' : ['Shougo/neosnippet-snippets', 'Shougo/context_filetype.vim', 'honza/vim-snippets'],
			\ 'insert' : 1,
			\ 'filetypes' : 'snippet',
			\ 'unite_sources' : [
			\    'neosnippet', 'neosnippet/user', 'neosnippet/runtime'],
			\ }
NeoBundle 'Shougo/vimproc.vim', {
			\ 'build' : {
			\     'windows' : 'make -f make_mingw32.mak',
			\     'cygwin' : 'make -f make_cygwin.mak',
			\     'mac' : 'make -f make_mac.mak',
			\     'unix' : 'make -f make_unix.mak',
			\    }
			\ }
NeoBundle 'Shougo/vimshell.vim', {
			\ 'commands' : [{ 'name' : 'VimShell',
			\                 'complete' : 'customlist,vimshell#complete'},
			\               'VimShellExecute', 'VimShellInteractive',
			\               'VimShellCreate',
			\               'VimShellTerminal', 'VimShellPop'],
			\ 'mappings' : '<Plug>(vimshell_'
			\ }
NeoBundle 'yomi322/vim-gitcomplete', {
			\ 'filetype' : 'vimshell'
			\ }
NeoBundle 'hail2u/vim-css3-syntax'
NeoBundle 'kana/vim-niceblock'
NeoBundle 'thinca/vim-quickrun', {
			\ 'commands' : 'QuickRun',
			\ 'mappings' : [
			\   ['nxo', '<Plug>(quickrun)']],
			\ }
NeoBundle 'thinca/vim-ref', {
			\ 'commands' : 'Ref',
			\ 'unite_sources' : 'ref',
			\ }
NeoBundle 'thinca/vim-unite-history', {
			\ 'unite_sources' : ['history/command', 'history/search']
			\ }
NeoBundle 'Shougo/unite-help'
NeoBundle 'tsukkee/unite-tag', {
			\ 'unite_sources' : ['tag', 'tag/include', 'tag/file']
			\ }
NeoBundle 'Shougo/unite-session'
NeoBundle 'ujihisa/neco-look'
NeoBundle 'osyo-manga/unite-filetype'
NeoBundle 'kana/vim-tabpagecd', {
			\ 'unite_sources' : 'tab'
			\ }
NeoBundle 'supermomonga/unite-kawaii-calc'
NeoBundleLazy 'godlygeek/csapprox', { 'terminal' : 1 }
NeoBundle 'tpope/vim-repeat', {
			\ 'mappings' : '.',
			\ }
NeoBundle 'matchit.zip', {
			\ 'mappings' : [['nxo', '%', 'g%']]
			\ }
NeoBundle 'Shougo/javacomplete', {
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
NeoBundleLazy 'Shougo/vim-vcs', {
			\ 'depends' : 'thinca/vim-openbuf',
			\ 'autoload' : {'commands' : 'Vcs'},
			\ }
NeoBundle 'tejr/vim-tmux'
NeoBundle 'xolox/vim-easytags', {
			\ 'depends' : 'xolox/vim-misc'
			\ }
NeoBundle 'pbrisbin/vim-mkdir'
" Disabled set timestamp doesn't work
"NeoBundle 'rhysd/auto-neobundle'
