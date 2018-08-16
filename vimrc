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

" Indent options
set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab 

" Tab options
map tp :tabp<cr>
map tn :tabn<cr>

" NERDTree
let g:NERDTreeMinimalUI=1
let g:NERDTreeDirArrows=1
map <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif


" From Damian Conway's talk at OSCON 2013
nnoremap ; :
"nnoremap : ;
highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%81v', 100)

" https://stackoverflow.com/questions/2157914/can-vim-monitor-realtime-changes-to-a-file
set autoread
autocmd CursorHold * call Timer()
function! Timer()
  checktime
  call feedkeys("f\e")
endfunction

set tabpagemax=50

map <C-t> :TagbarToggle<CR>
let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : '$GOPATH/bin/gotags',
    \ 'ctagsargs' : '-sort -silent'
\ }

let g:go_fmt_command = "goimports"
let g:syntastic_go_checkers = ['go', 'golint']
"let g:syntastic_go_checkers = ['golint']
"let g:syntastic_go_go_build_args = "-o /dev/null -i"
"let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }


" http://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
let mapleader = "\<Space>"
nnoremap <Leader>w :w<CR>
nnoremap <Leader>t :NERDTreeToggle<CR>
nnoremap <Leader>x :x<CR>
nnoremap <Leader>q :q<CR>

" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Highlight whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+\%#\@<!$/

filetype plugin indent on
