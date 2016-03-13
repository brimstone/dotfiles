autocmd FileType c call FileType_c()
function! FileType_c()
	set omnifunc=ccomplete#Complete
endfunction
