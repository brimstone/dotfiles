autocmd FileType html call FileType_html()
function! FileType_html()
	set omnifunc=htmlcomplete#CompleteTags
	set tabstop=2
	set softtabstop=2
	set shiftwidth=2
	set expandtab
	autocmd BufWritePost * silent !tidy -im <afile> > /dev/null 2>/dev/null
endfunction
