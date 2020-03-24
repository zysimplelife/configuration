set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
set rtp+=~/.fzf
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-vinegar'
Plugin 'scrooloose/syntastic'
Plugin 'martinda/Jenkinsfile-vim-syntax'
Plugin 'scrooloose/nerdcommenter'
Plugin 'Raimondi/delimitMate'
Plugin 'fatih/vim-go'
Plugin 'junegunn/fzf.vim'


" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
" private configurations
" load bash profile
set nu

" disable recording macros: I hit this key accidentally too often
nnoremap q <Nop>

"use space for tab
set tabstop=4
set shiftwidth=4    " Indents will have a width of 4
set softtabstop=4   " Sets the number of columns for a TAB
set expandtab       " Expand TABs to spaces

"youCompleteMe
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_autoclose_preview_window_after_completion = 1
"netrw configuration
"let g:netrw_banner = 0
"let g:netrw_liststyle = 3
"let g:netrw_browse_split = 4
"let g:netrw_altv = 1
"let g:netrw_winsize = 25


" auto format go "
let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"
"let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck']

autocmd FileType go nmap <leader>b  <Plug>(go-build)

" hight light end whitespace
autocmd bufenter * match Error /\s\+$/
" auto change directory to directory containing current file
autocmd BufEnter * silent! lcd %:p:h


"golint
set rtp+=$GOPATH/src/golang.org/x/lint/misc/vim
"autocmd BufWritePost,FileWritePost *.go execute 'Lint' | cwindow
