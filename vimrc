" need to further review http://amix.dk/vim/vimrc.html
map <Esc>j <C-W>j
map <Esc>k <C-W>k
map <Esc>h <C-W>h
map <Esc>l <C-W>l

" Uncomment the following to have Vim jump to the last position when reopening a file
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif

" supa-awesome syntax highlighting
syntax on
filetype on
set background=dark
" set cakephp's template extension
au BufNewFile,BufRead *.ctp set filetype=php


" auto close html tags while editing
" au Filetype html,xml,xsl,php source ~/.vim/scripts/closetag.vim

set foldmethod=indent "zo to open, zc to close
set foldlevel=99

set number	" turn on line numbers
set showmatch	" show matching braces and brackets
set hlsearch	" highlight search results
set incsearch	" show the first matching result while searching for results
set history=10	" disable our search history

" set status line
set statusline=%<%f\ %h%m%r%=%-20.(line=%l,col=%c%V,totlin=%L%)
set laststatus=2 

set encoding=utf-8
set modeline

" Intellisense!
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType c call FileType_c()
autocmd BufNewFile,BufRead *.md set filetype=markdown
autocmd FileType markdown call FileType_txt()
autocmd BufNewFile,BufRead *.txt call FileType_txt()

setlocal omnifunc=syntaxcomplete#Complete
"set cot+=menuone

" for mouse support inside screen
set ttymouse=xterm2
"set mouse=a

" use w!! after you open a file to save it with sudo
cmap w!! w !sudo tee % >/dev/null
"cmap W w
"cmap Q q

" Press F4 to toggle highlighting on/off, and show current value.
:noremap <F4> :set hlsearch! hlsearch?<CR>

map <F5> :!clear; make && make test <RETURN>
set t_Co=256 

function! FileType_txt()
	set spell spelllang=en_us
endfunction

function! FileType_c()
	set omnifunc=ccomplete#Complete
endfunction

" Pathogen
call pathogen#infect()

" Solarize
let g:solarized_termtrans = 1
let g:solarized_termcolors=256
set background=dark
colorscheme solarized

" Powerline
let g:Powerline_symbols = 'fancy'
"let g:Powerline_theme = 'solarized256'
let g:Powerline_colorscheme = 'solarized256'

" Network Oriented Reading, Writing and Browsing
let g:netrw_silent	= 1

" Tab options
set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab 

" Unite
nnoremap <C-o> :Unite file<cr>
nnoremap <C-t> :Unite tab<cr>
