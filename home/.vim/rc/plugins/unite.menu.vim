call unite#custom#profile('menu', 'context', {
			\ 'buffer-name': 'menu',
			\ 'start_insert': 0,
			\ 'prompt-direction': 'top',
			\ 'toggle': 1,
			\ 'auto-resize': 0,
			\ 'winwidth': 10,
			\ 'vertical': 1,
			\ 'direction': 'topleft'
			\ })

let g:unite_source_menu_menus = {}
let g:unite_source_menu_menus.Main = {} 
let g:unite_source_menu_menus.Main.command_candidates = {
			\       'File'   : 'Unite -profile-name=menu menu:File',
			\       'test'   : 'Unite menu:unite',
			\       'mac'    : 'WMa}',
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

let g:unite_source_menu_menus.git = {
			\ 'description' : 'gestionar repositorios git  ⌘ [espacio]g',
			\}
let g:unite_source_menu_menus.git.command_candidates = [
			\['▷ tig                                                        ⌘ ,gt',
			\'normal ,gt'],
			\['▷ git status       (Fugitive)                                ⌘ ,gs',
			\'Gstatus'],
			\['▷ git diff         (Fugitive)                                ⌘ ,gd',
			\'Gdiff'],
			\['▷ git commit       (Fugitive)                                ⌘ ,gc',
			\'Gcommit'],
			\['▷ git log          (Fugitive)                                ⌘ ,gl',
			\'exe "silent Glog | Unite quickfix"'],
			\['▷ git blame        (Fugitive)                                ⌘ ,gb',
			\'Gblame'],
			\['▷ git stage        (Fugitive)                                ⌘ ,gw',
			\'Gwrite'],
			\['▷ git checkout     (Fugitive)                                ⌘ ,go',
			\'Gread'],
			\['▷ git rm           (Fugitive)                                ⌘ ,gr',
			\'Gremove'],
			\['▷ git mv           (Fugitive)                                ⌘ ,gm',
			\'exe "Gmove " input("destino: ")'],
			\['▷ git push         (Fugitive, salida por buffer)             ⌘ ,gp',
			\'Git! push'],
			\['▷ git pull         (Fugitive, salida por buffer)             ⌘ ,gP',
			\'Git! pull'],
			\['▷ git prompt       (Fugitive, salida por buffer)             ⌘ ,gi',
			\'exe "Git! " input("comando git: ")'],
			\['▷ git cd           (Fugitive)',
			\'Gcd'],
			\]

