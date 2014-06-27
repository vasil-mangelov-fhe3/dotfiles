call unite#custom#profile('menu', 'context', {
			\ 'buffer-name': 'menu',
			\ 'start_insert': 0,
			\ 'prompt-direction': 'top',
			\ 'auto-resize': 0,
			\ 'winwidth': 35,
			\ 'vertical': 1,
			\ 'direction': 'topleft'
			\ })

let s:unite_call_menu = 'Unite -profile-name=menu menu:'

let g:unite_source_menu_menus = {}
let g:unite_source_menu_menus.Main = {}
let g:unite_source_menu_menus.Main.command_candidates = {
			\       'File'   : s:unite_call_menu . 'File',
			\       'Git'    : s:unite_call_menu . 'Git',
			\     }
let g:unite_source_menu_menus.File = {
			\     'description' : 'Change file format option.',
			\ }
let g:unite_source_menu_menus.File.command_candidates = {
			\       'unix'   : 'WUnix',
			\       'dos'    : 'WDos',
			\       'mac'    : 'WMa}',
			\     }

let g:unite_source_menu_menus.unite = {
			\     'description' : 'Start unite sources',
			\ }
let g:unite_source_menu_menus.unite.command_candidates = {
			\       'history'    : 'Unite history/command',
			\       'quickfix'   : 'Unite qflist -no-quit',
			\       'resume'     : 'Unite -buffer-name=resume resume',
			\       'directory'  : 'Unite -buffer-name=files '.
			\             '-default-action=lcd directory_mru',
			\       'mapping'    : 'Unite mapping',
			\       'message'    : 'Unite output:message',
			\       'scriptnames': 'Unite output:scriptnames',
			\     }

let g:unite_source_menu_menus.Git = {
			\ 'description' : 'gestionar repositorios git  ⌘ [espacio]g',
			\}
let g:unite_source_menu_menus.Git.command_candidates = [
			\['ᐊᐊ Back','Unite -profile-name=menu menu:Main'],
			\[' ᐅ git status	[LEADER]gs','Gstatus'],
			\[' ᐅ git diff		[LEADER]gd','Gdiff'],
			\[' ᐅ git commit	[LEADER]gc','Gcommit'],
			\[' ᐅ git log		[LEADER]⌘ ,gl','exe "silent Glog | Unite quickfix"'],
			\[' ᐅ git blame		[LEADER]⌘ ,gb','Gblame'],
			\[' ᐅ git stage		[LEADER]⌘ ,gw','Gwrite'],
			\[' ᐅ git checkout	[LEADER]⌘ ,go','Gread'],
			\[' ᐅ git rm		[LEADER]⌘ ,gr','Gremove'],
			\[' ᐅ git mv		[LEADER]⌘ ,gm','exe "Gmove " input("Destination: ")'],
			\[' ᐅ git push		[LEADER]⌘ ,gp','Git! push'],
			\[' ᐅ git pull		[LEADER]⌘ ,gP','Git! pull'],
			\[' ᐅ git prompt	<leader>gi','exe "Git! " input("Git command: ")'],
			\[' ᐅ git cd','Gcd'],
			\]

