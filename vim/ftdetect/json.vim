autocmd FileType json call FileType_json()
function! FileType_json()
	autocmd BufWritePost * silent !jsonlint -i <afile> > /dev/null 2>/dev/null
endfunction
