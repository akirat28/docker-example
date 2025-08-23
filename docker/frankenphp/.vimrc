:set encoding=utf-8
:set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8

set nocompatible
filetype off
set backspace=indent,eol,start

filetype plugin indent on

syntax enable

set autoindent
set smartindent

set tabstop=4
set shiftwidth=4
set expandtab


set incsearch
set hlsearch

set laststatus=2

set autoread

set confirm

au BufRead,BufNewFile *.php set filetype=php
au FileType php setlocal omnifunc=phpcomplete#CompletePHP
au FileType php setlocal formatoptions+=cro

if has("autocmd") && exists("+omnifunc")
    autocmd FileType php set omnifunc=syntaxcomplete#Complete
endif

: Vim-Plug
call plug#begin('~/.vim/plugged')

Plug 'StanAngeloff/php.vim'
Plug '2072/PHP-Indenting-for-VIm'
Plug 'vim-vdebug/vdebug'

call plug#end()

: Vdebug
let g:vdebug_options = {}
let g:vdebug_options['port'] = 9003
let g:vdebug_options['on_close'] = 'stop'
let g:vdebug_options['watch_window_style'] = 'compact'
let g:vdebug_options['break_on_open'] = 0
let g:vdebug_options['window_arrangement'] = 'right'
