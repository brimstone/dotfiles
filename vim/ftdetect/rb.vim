autocmd FileType ruby call FileType_rb()
function! FileType_rb()
	set tabstop=2
	set softtabstop=2
	set shiftwidth=2
	set expandtab
	autocmd BufWritePost * silent !rubocop -a <afile> > /dev/null 2>/dev/null
endfunction
