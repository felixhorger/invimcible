set nocp

" Syntax
syntax on
set number
colo BusyBee
let g:matchparen_timeout=50
let g:matchparen_insert_timeout=50

" Tabs
set tabstop=4
set shiftwidth=4
set autoindent
set noexpandtab
" Tablabels, copied from vim :help setting-tabline and modified
function TabLine()
	let s = ''
	for i in range(tabpagenr('$'))
		" select the highlighting
		if i + 1 == tabpagenr()
			let s .= '%#TabLineSel#'
		else
			let s .= '%#TabLine#'
		endif
		" set the tab page number (for mouse clicks)
		let s .= '%' . (i + 1) . 'T'
		" the label is made by TabLabel()
		let s .= ' %{TabLabel(' . (i + 1) . ')} '
	endfor
	" after the last tab fill with TabLineFill and reset tab page nr
	let s .= '%#TabLineFill#%T'
	return s
endfunction
"
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
	return label . bufname(bufnrlist[tabpagewinnr(a:n)[1]])
endfunction
set tabline=%!TabLine()

" Window
let &winheight=16
set splitbelow
set splitright

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

" Misc
set nowrap
set clipboard=exclude:cons\|linux " Removes lag from xvcserver upon selection (selection not copied anymore)
set wildmode=longest,list
set autochdir " Update working dir

" Slime
let g:slime_target = "vimterminal"
let g:slime_vimterminal_config = {"term_finish": "close"}
let g:slime_vimterminal_cmd = "pickyourpoison"
let g:slime_no_mappings = 1
xmap <BS> <Plug>SlimeRegionSend
nmap <BS> <Plug>SlimeParagraphSend
nmap <Del> <Plug>SlimeLineSend
"nmap <Tab> <Plug>SlimeSendCell
command! -nargs=0 ReplNoClose let g:slime_vimterminal_config = {}
command! -nargs=0 ReplDoClose let g:slime_vimterminal_config = {"term_finish": "close"}
function PickYourPoison()
	let w:ServerName=get(w:, "ServerName", "local")
	if w:ServerName == "local"
		let g:slime_vimterminal_cmd="pickyourpoison"
	else
		let l:wd=system("pwd | tr -d '\\n' | replace your stuff'")
		let g:slime_vimterminal_cmd="ssh -XC " . w:ServerName . " -t bash -il -c 'cd " . l:wd . " && pickyourpoison'"
	endif
endfunction
command! -nargs=0 Repl call PickYourPoison() | SlimeConfig
command! -nargs=0 Local let w:ServerName="local" | call PickYourPoison()
command! -nargs=0 WhateverServer let w:ServerName="whatever server you like" | call PickYourPoison()

" Cursor Problems, all didn't really work out
"let &t_SI = "\e[%p1%d q"
"let &t_EI = "\e[%p1%d q"
"let &t_TI = "\e[?1047h\e[22;0;0t"
"let &t_TE = "\e[?1047l\e[23;0;0t"
"let &t_ti = "\e[?1049h\e[22;0;0t"
"let &t_te = "\e[?1049l\e[23;0;0t"
"set t_fd= " Sent to terminal upon losing/gaining focus
"set t_fe=
" VimLeave !echo -e '\e[?1049l'

