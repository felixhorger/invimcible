set nocp

" Syntax
syntax on
set number
colo railcasts
let g:matchparen_timeout=50
let g:matchparen_insert_timeout=50

" Tabs
set tabstop=8
set shiftwidth=8
set autoindent
set noexpandtab
" Tablabels, copied from vim :help setting-tabline and modified
function TabLine()
	let s = ''
	for i in range(tabpagenr('$'))
		let i = i+1
		" select the highlighting
		if i == tabpagenr()
			let s .= '%#TabLineSel#'
		else
			let s .= '%#TabLine#'
		endif
		" set the tab page number (for mouse clicks)
		let s .= '%' . i . 'T'
		" the label is made by TabLabel()
		let s .= ' %{TabLabel(' . i . ')} '
	endfor
	" after the last tab fill with TabLineFill and reset tab page nr
	let s .= '%#TabLineFill#%T'
	return s
endfunction
function TabLabel(n)
	let label = a:n
	let bufnrlist = tabpagebuflist(a:n)
	" Add '+' if one of the buffers in the tab page is modified
	for bufnr in bufnrlist
		if getbufvar(bufnr, "&modified")
			let label .= '+'
			break
		endif
	endfor
	" Append the number of windows in the tab page if more than one
	"let wincount = tabpagewinnr(a:n, '$')
	"if wincount > 1
	"	let label .= wincount
	"endif
	" Append space
	let label .= ' '
	" Append the buffer name of the first window in that buffer
	let path = fnamemodify(bufname(bufnrlist[tabpagewinnr(a:n)[1]]), ':p:.')
	if path == ''
		let path = '[No Name]'
	endif
	let length = len(path)
	if length > 32
		let path = path[length-32:length-1]
	endif
	return label . path
endfunction
set tabline=%!TabLine()

" Window
let &winheight=HERE
set splitbelow
set splitright

" Misc
set nowrap
set clipboard=exclude:cons\|linux " Removes lag from xvcserver upon selection (selection not copied anymore)
set wildmode=longest,list
set autochdir " Update working dir

" Keys
set timeoutlen=1 "Speed up key combinations
" Disable unwanted keys
map <Up> <Nop>
map <Down> <Nop>
map <Left> <Nop>
map <Right> <Nop>
map <Del> <Nop>
map <BS> <Nop>
" set termwinkey=<whatever> in case you need C-W in terminal
" Slime and Repl keys
xmap <BS> <Plug>SlimeRegionSend
nmap <BS> <Plug>SlimeParagraphSend
nmap <Del> <Plug>SlimeLineSend
"nmap <Tab> <Plug>SlimeSendCell
"nmap <C-j> <C-w>w<C-b>[
"nmap <C-k> i<C-w>:call term_sendkeys(bufnr('%'), "q")<CR><C-w>w<C-l>
nmap <C-j> <C-w>w<C-w>N<C-u>
nmap <C-k> i<C-w>w

" Slime and Repl
let g:repl = "HERE"
let g:slime_target = "vimterminal"
let g:slime_vimterminal_config = {"term_finish": "close"}
let g:slime_no_mappings = 1
command! -nargs=0 ReplNoClose let g:slime_vimterminal_config = {}
command! -nargs=0 ReplDoClose let g:slime_vimterminal_config = {"term_finish": "close"}
function ReplReplaceUser(path)
	let l:local = expand("$HOME")
	let l:path = substitute(a:path, l:local, "$HOME", "g")
	return l:path
endfunction
function ReplRemotePath()
	let l:wd = getcwd()
	" HERE your own replaces
	let l:wd = ReplReplaceUser(l:wd)
	return l:wd
endfunction
function ConfigureRepl(...)
	let w:server = get(w:, "server", "local")
	if w:server == "local"
		let g:slime_vimterminal_cmd = expand(g:repl)
	else
		if a:0 == 0
			let l:commands = [ "ssh -XC " . w:server . " -t bash -il -c '",
				\ "vimrepl=0;",
				\ "while [ `tmux has -t vimrepl$vimrepl 2>1; echo $?` -eq 0 ];",
				\	"do let \"vimrepl=vimrepl+1\";",
				\ "done;",
				\ "vimrepl=vimrepl$vimrepl;",
				\ "tmux new-session -d -s $vimrepl cd " . ReplRemotePath() . " && " . g:repl . ";",
				\ "tmux set -t $vimrepl -as terminal-overrides \\',xterm-256color:smcup@:rmcup@\\';",
				\ "tmux attach -t $vimrepl;'"
			\]
			let g:slime_vimterminal_cmd = join(l:commands, '')
			"Debug if needed echo g:slime_vimterminal_cmd
			" Without tmux
			"let g:slime_vimterminal_cmd = "ssh -XC " . w:server . " -t bash -il -c 'cd " . ReplRemotePath() . " && " . g:repl . "'"
		elseif a:0 == 1
			let g:slime_vimterminal_cmd = "ssh -XC " . w:server . " -t tmux attach -t " . a:1
		elseif a:0 > 1
			throw "Expected either no arguments or the tmux session"
		end
	endif
endfunction

command! -nargs=? Repl call ConfigureRepl(<f-args>) | SlimeConfig
command! -nargs=0 Local let w:server = "local"
"Your own servers

