"------------------------------------------------------------------------------
"# Options #-------------------------------------------------------------------

set nocompatible                " disable vi-compatible mode
set encoding=utf-8
scriptencoding utf-8
filetype plugin indent on

" window & split behavior
set splitright                  " open vertical splits to the right
set splitbelow                  " open horizontal splits below
set scrolloff=5                 " keep 5 lines visible above/below cursor

" display & visual
set number                      " show line numbers
set relativenumber              " show relative line numbers
set cursorline                  " highlight the current line
if has('termguicolors')
    set termguicolors           " enable 24-bit RGB colors
endif
set laststatus=0                " hide the statusline
set noruler                     " /etc/vim/vimrc forces 'ruler' on, which would survive laststatus=0
set linebreak                   " wrap long lines at word boundaries
set textwidth=80                " wrap text at column 80
set visualbell                  " use visual bell instead of beeping
set showmatch                   " briefly jump to matching bracket
syntax enable                   " enable syntax highlighting

" search behavior
set hlsearch                    " highlight all search matches
set incsearch                   " show search matches as you type
set ignorecase                  " case-insensitive search by default
set smartcase                   " case-sensitive search when query has uppercase

" indentation & tabs
set autoindent                  " copy indent from current line on newline
set smartindent                 " smart auto-indenting for new lines
set breakindent                 " preserve indent on wrapped lines
set tabstop=4                   " how wide a tab *displays*
set shiftwidth=4                " how much >>, << indent by
set softtabstop=0               " no "soft tab" fakery, let tabstop govern
set noexpandtab                 " pressing <Tab> inserts a real tab char
set smarttab                    " Tab at line start uses shiftwidth/tabstop

" completion
set complete=.,w,b,u,t          " sources for <C-n>/<C-p> completion
set completeopt=menuone,noselect
set pumheight=10                " popup menu height

" editor defaults
set undolevels=1000             " maximum undo levels
set autoread                    " read live changes made outside of vim
set grepprg=rg\ --vimgrep       " use ripgrep for :grep
set shortmess+=I                " suppress the intro message on startup
set guioptions-=e               " disable GUI tab pages line
set backspace=indent,eol,start  " allow backspace over everything

" visual noise
set list
set listchars=tab:▏\ ,trail:░,nbsp:░

" file explorer (netrw)
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_sort_options = "i"
let g:netrw_bufsettings = "noma nomod nu nobl nowrap ro rnu"

" load after the editor is up
augroup vimrc_late
    autocmd!
    autocmd VimEnter * set clipboard=unnamedplus | set rtp+=/opt/homebrew/opt/fzf
augroup END


"------------------------------------------------------------------------------
"# Default Override #----------------------------------------------------------

" NOTE: <leader> is the default backslash, same as in the lua config.
" NOTE: <M-...> maps need a terminal that sends real Alt (or Esc+key); they
"       work out of the box in gvim/MacVim and most modern terminals.

" save, creating missing parent dirs (nvim's ':wq ++p'), then quit
nnoremap <silent> ZZ :call mkdir(expand('%:p:h'), 'p') <Bar> wq<CR>
nnoremap <silent> S "_d$a
nnoremap <silent> X "_x
nnoremap <silent> s "_d
xnoremap <silent> s "_d
nnoremap <silent> <Esc> <Esc>:noh<CR>

" Use 'c' to enter Visual Block mode
nnoremap <silent> c <C-v>
xnoremap <silent> c <C-v>


"------------------------------------------------------------------------------
"# cxxx #----------------------------------------------------------------------

" ctags
nnoremap <silent> <leader>td <C-]>
nnoremap <silent> <leader>tb <C-t>
nnoremap <silent> <leader>ts :tselect <C-r><C-w><CR>
nnoremap <silent> <leader>tl :tlist <C-r><C-w><CR>
nnoremap <silent> <leader>tt :tag <C-r><C-w><CR>
nnoremap <silent> <leader>tj :tnext<CR>
nnoremap <silent> <leader>tk :tprev<CR>
nnoremap <silent> <leader>t0 :tfirst<CR>
nnoremap <silent> <leader>t$ :tlast<CR>
nnoremap <silent> <leader>tx :tags<CR>

" quickfixes
nnoremap <silent> <leader>qo :copen<CR>
nnoremap <silent> <leader>qq :cclose<CR>
nnoremap <silent> <leader>ql :clist<CR>
nnoremap <silent> <leader>qj :cnext<CR>
nnoremap <silent> <leader>qk :cprev<CR>
nnoremap <silent> <leader>q0 :cfirst<CR>
nnoremap <silent> <leader>q$ :clast<CR>


"------------------------------------------------------------------------------
"# Windows #-------------------------------------------------------------------

" toggle color column
function! ToggleColumn() abort
    if &l:colorcolumn ==# ''
        setlocal colorcolumn=81,101
    else
        setlocal colorcolumn=
    endif
endfunction
nnoremap <silent> <leader>l :call ToggleColumn()<CR>

" toggle horizontal/vertical panes
let s:pane_type = 'vertical'
function! RotatePanes() abort
    if s:pane_type ==# 'horizontal'
        let s:pane_type = 'vertical'
        wincmd K
    else
        let s:pane_type = 'horizontal'
        wincmd H
    endif
endfunction
nnoremap <silent> <leader>w :call RotatePanes()<CR>

" explore and panes
nnoremap <silent> ZE :Ex<CR>
nnoremap <silent> ZH :vsplit <Bar> Explore<CR>
nnoremap <silent> ZV :split  <Bar> Explore<CR>

" Move splits with <C-w>h/j/k/l instead of navigating
nnoremap <silent> <C-w>h <C-w>H
nnoremap <silent> <C-w>j <C-w>J
nnoremap <silent> <C-w>k <C-w>K
nnoremap <silent> <C-w>l <C-w>L


"------------------------------------------------------------------------------
"# Conveniences #--------------------------------------------------------------

command! -nargs=0 W w
command! -nargs=0 Wq wq
cnoremap w!! w !sudo tee > /dev/null %

" to whole file
nnoremap <silent> sA gg"_dG<CR>
nnoremap <silent> dA :%delete<CR>
nnoremap <silent> yA :%yank<CR>
nnoremap <silent> <leader>R gg"_dGp<CR>
nnoremap <silent> =A myLgg=G``zb`y<CR>:%s/ *$//g<CR>

" faster actions
nnoremap <silent> <space>/ /--#<CR> kztj<CR>
nnoremap <space>s :%s/
nnoremap <silent> <M-z> zfi{
nnoremap <silent> <M-Z> zo
nnoremap <silent> <M-j> <Esc>jzz<CR>


"------------------------------------------------------------------------------
"# Inserts #-------------------------------------------------------------------

" autoclose brackets: get in
inoremap <silent> <M-9> ()<Left>
inoremap <silent> <M-{> {}<Left>
inoremap <silent> <M-[> []<Left>
inoremap <silent> <M-"> ""<Left>
inoremap <silent> <M-'> ''<Left>

" autoclose brackets: stay out
inoremap <silent> <M-0> ()
inoremap <silent> <M-)> ( void )<CR>{<CR>}<Esc>O
inoremap <silent> <M-]> []
inoremap <silent> <M-}> {}

" common actions
inoremap <silent> <M-;> <Esc>A;
inoremap <silent> <M-=> <Space>==<Space>
inoremap <silent> <M-+> <Space>!=<Space>

" hjkl nav in insert mode
inoremap <silent> <M-h> <Left>
inoremap <silent> <M-j> <Down>
inoremap <silent> <M-k> <Up>
inoremap <silent> <M-l> <Right>
