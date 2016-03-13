autocmd FileType yaml call FileType_yaml()

function! FileType_yaml()
	set tabstop=2
	set softtabstop=2
	set shiftwidth=2
	set expandtab
endfunction
