autocmd FileType python call FileType_py()
function! FileType_py()
	set tabstop=4
	set softtabstop=4
	set shiftwidth=4
	set expandtab
	autocmd BufWritePost * silent !autopep8 -i <afile> > /dev/null 2>/dev/null
endfunction
