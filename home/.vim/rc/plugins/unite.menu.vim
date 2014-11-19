call unite#custom#profile('menu', 'context', {
			\ 'buffer-name': 'menu',
			\ 'start_insert': 0,
			\ 'prompt-direction': 'top',
			\ 'auto-resize': 0,
			\ 'winwidth': 35,
			\ 'vertical': 1,
			\ 'direction': 'topleft',
			\ 'toggle': 1,
			\ 'quick-match' : 1,
			\ })

let s:unite_call_menu = 'Unite -profile-name=menu menu:'

let g:unite_source_menu_menus = {}
let g:unite_source_menu_menus.Main = {}
let g:unite_source_menu_menus.Main.command_candidates =[
			\ ['>> File', s:unite_call_menu . 'File'],
			\ ['>> Git', s:unite_call_menu . 'Git'],
			\ [' > Help', 'Startify'],
			\ ]

let g:unite_source_menu_menus.File = {}
let g:unite_source_menu_menus.File.command_candidates = [
			\ ['<< Back', s:unite_call_menu . 'Main'],
			\ [' > New', 'Unite file/new'],
			\ [' > Open', 'edit '],
			\ [' > Save', 'write'],
			\ [' > Recently opened', 'Unite file_mru'],
			\ ]

let g:unite_source_menu_menus.unite = {
			\ 'description' : 'Start unite sources',
			\ }
let g:unite_source_menu_menus.unite.command_candidates = {
			\ 'history'    : 'Unite history/command',
			\ 'quickfix'   : 'Unite qflist -no-quit',
			\ 'resume'     : 'Unite -buffer-name=resume resume',
			\ 'directory'  : 'Unite -buffer-name=files '.'-default-action=lcd directory_mru',
			\ 'mapping'    : 'Unite mapping',
			\ 'message'    : 'Unite output:message',
			\ 'scriptnames': 'Unite output:scriptnames',
			\ }

let g:unite_source_menu_menus.Git = {}
let g:unite_source_menu_menus.Git.command_candidates = {
			\ '<< Back': s:unite_call_menu . 'Main',
			\ ' > git status	<Leader>gs': 'Gstatus',
			\ ' > git diff		<Leader>gd': 'Gdiff',
			\ ' > git commit	<Leader>gc': 'Gcommit',
			\ ' > git log		<Leader>gl': 'exe "silent Glog | Unite quickfix"',
			\ ' > git blame		<Leader>gb': 'Gblame',
			\ ' > git stage		<Leader>gw': 'Gwrite',
			\ ' > git checkout	<Leader>go': 'Gread',
			\ ' > git rm		<Leader>gr': 'Gremove',
			\ ' > git mv		<Leader>gm': 'exe "Gmove " input("Destination: ")',
			\ ' > git push		<Leader>gp': 'Git! push',
			\ ' > git pull		<Leader>gP': 'Git! pull',
			\ ' > git prompt	<Leader>git': 'exe "Git! " input("Git command: ")',
			\ ' > git cd': 'Gcd',
			\ }

