set nocp

" Syntax
syntax on
set number
colo HERE
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
let &winheight=16
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
nmap <C-j> <C-w>w<C-w>N<C-u>
nmap <C-k> i<C-w>w

" Slime and Repl
let g:repl = "HERE"
let g:repl_localuser = "HERE"
let g:repl_remoteuser = "HERE"
let g:slime_target = "vimterminal"
let g:slime_vimterminal_config = {"term_finish": "close"}
let g:slime_no_mappings = 1
command! -nargs=0 ReplNoClose let g:slime_vimterminal_config = {}
command! -nargs=0 ReplDoClose let g:slime_vimterminal_config = {"term_finish": "close"}
function ReplReplaceUser(path)
	return substitute(a:path, "/home/" . g:repl_localuser, "/home/" . g:repl_remoteuser, "g")
endfunction
function ReplRemotePath()
	let l:wd = getcwd()
	" HERE any substitutions you need
	return ReplReplaceUser(l:wd)
endfunction
function ConfigureRepl(...)
	let w:server = get(w:, "server", "local")
	if w:server == "local"
		let g:slime_vimterminal_cmd = "sh -c \"" . g:repl . "\""
	else
		if a:0 == 0
			let g:slime_vimterminal_cmd = "ssh -XC " . w:server . " -t tmux new-session 'cd " . ReplRemotePath() . " && " . g:repl . "'"
		elseif a:0 == 1
			let g:slime_vimterminal_cmd = "ssh -XC " . w:server . " -t tmux attach -t " . a:1
		elseif a:0 > 1
			throw "Expected either no arguments or the tmux session"
		end
	endif
endfunction

command! -nargs=? Repl call ConfigureRepl(<f-args>) | SlimeConfig
command! -nargs=0 Local let w:server = "local"
command! -nargs=0 HERE let w:server = "HERE"
"HERE more servers

