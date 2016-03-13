autocmd BufNewFile,BufRead *.md set filetype=markdown
autocmd FileType markdown call FileType_txt()
autocmd FileType gitcommit call FileType_txt()
autocmd BufNewFile,BufRead *.txt call FileType_txt()

function! FileType_txt()
	set spell spelllang=en_us
endfunction
