autocmd FileType haskell call FileType_hs()
function! FileType_hs()
	set tabstop=4
	set softtabstop=4
	set shiftwidth=4
	set expandtab
endfunction
