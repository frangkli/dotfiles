let mapleader = ","

" ==================== PLUGINS ==================== {{{1
" Install vimplug {{{2
if ! filereadable(expand('~/.config/nvim/autoload/plug.vim'))
    echo "Downloading junegunn/vim-plug to manage plugins..."
    silent !mkdir -p ~/.config/nvim/autoload/
    silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ~/.config/nvim/autoload/plug.vim
endif

" Plug sources {{{2
call plug#begin('~/.config/nvim/plugged')

" Universal editing {{{3
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'SirVer/ultisnips'
Plug 'unblevable/quick-scope'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/goyo.vim'

" Completion {{{3
Plug 'metalelf0/supertab'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }

" File tree {{{3
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" Status line {{{3
Plug 'ryanoasis/vim-devicons'
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Git {{{3
Plug 'tpope/vim-fugitive'

" Color and highlights {{{3
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'dylanaraps/wal.vim'
Plug 'octol/vim-cpp-enhanced-highlight', { 'for': ['c', 'cpp'] }
Plug 'ap/vim-css-color'

" Note taking {{{3
Plug 'vimwiki/vimwiki'
Plug 'suan/vim-instant-markdown', { 'for': 'markdown' }
Plug 'lervag/vimtex', { 'for': ['tex', 'bib'] }
Plug 'KeitaNakamura/tex-conceal.vim', { 'for': ['tex'] }
Plug 'rhysd/vim-grammarous', { 'on': 'GrammarousCheck' }

" Frontend development {{{3
Plug 'maxmellon/vim-jsx-pretty', { 'for': ['javascript', 'jsx', 'javascriptreact'] }
Plug 'alvan/vim-closetag', { 'for': ['javascript', 'jsx', 'javascriptreact', 'html', 'xml'] }
call plug#end()

" ==================== BASICS ==================== {{{1
" Quality of life {{{2
set background=dark                                     " Use dark background
set mouse=a                                             " Allow mouse clicks
set number                                              " Show line numbers
set relativenumber                                      " Make line numbers relative
set hlsearch                                            " Highlight search results
set autoread                                            " Reopen file when changed externally
set wrap                                                " Wrap lines
set title                                               " Set terminal title on enter
set titleold=st                                         " Revert title on exit
set clipboard=unnamedplus                               " Use mac clipboard
set undodir=~/.config/nvim/undodir                      " Undo record directory
set undofile                                            " Default undofile name
set encoding=UTF-8                                      " UTF-8 encoding
set noshowmode                                          " Stop showing mode in prompt
set hidden                                              " Keep buffers loaded
set lazyredraw                                          " Prevent screen redraw when executing macros
set expandtab                                           " Change tabs into spaces
set tabstop=4                                           " Number of spaces of <Tab>
set shiftwidth=4                                        " Indent size
set smarttab                                            " Change tab size based on context
set backspace=2                                         " Allow <BS> for indent, eol, start
set dictionary=~/.config/nvim/spell/en.utf-8.add        " User-defined spelling file
set viminfo+='1000,n$XDG_DATA_HOME/vim/viminfo          " Move viminfo to XDG
set foldmethod=indent                                   " Indent as primary foldmethod
set foldlevel=1                                         " Open all folds by default
set splitbelow                                          " Horizontal split to the bottom
set splitright                                          " Vertical split to the right
set conceallevel=2                                      " Completely hide concealed
set wildmode=longest,list,full                          " Complete longest common string, list all, complete next
set rtp+=../UltiSnips                                   " Always look for UltiSnips folder in parent
filetype plugin indent on                               " Use filetype specific plugin and indent
syntax on                                               " Turn on syntax

" Coc settings {{{2
set nobackup                                            " Don't make backups
set nowritebackup                                       " Don't make temporary backups
set updatetime=300                                      " Swap and CursorHold duration
set signcolumn=auto                                     " Show signcolumn on demand
set shortmess+=c                                        " Don't show completion log

" ==================== COLORS ==================== {{{1
color wal
highlight CursorLine ctermbg=9 cterm=none
highlight CursorColumn ctermbg=9
highlight CursorLineNr ctermfg=2
highlight WildMenu ctermfg=0 ctermbg=3
highlight Statusline ctermfg=7 ctermbg=none cterm=none
highlight Pmenu ctermbg=233
highlight PmenuSel ctermfg=0 ctermbg=3
highlight QuickScopePrimary cterm=underline ctermfg=155
highlight QuickScopeSecondary cterm=underline ctermfg=81
highlight CocErrorFloat ctermfg=3
highlight Statement ctermfg=3
highlight Identifier cterm=none
highlight Conceal ctermbg=none
highlight vimUserCommand ctermfg=10
highlight htmlItalic cterm=italic ctermfg=5

" ==================== PLUGIN VARIABLES ===================== {{{1
" limelight.vim
let g:limelight_priority = -1

" ultisnips {{{2
let g:UltiSnipsEditSplit = "vertical"
let g:UltiSnipsExpandTrigger = "<Tab>"
let g:UltiSnipsJumpForwardTrigger="<C-j>"
let g:UltiSnipsJumpBackwardTrigger="<C-k>"

" supertab {{{2
let g:SuperTabDefaultCompletionType = "<C-n>"

" coc.nvim {{{2

" vimtex {{{2
let g:vimtex_compiler_progname = 'nvr'
let g:vimtex_view_general_viewer = 'dothura'
let g:vimtex_fold_enabled = 1
let g:vimtex_matchparen_enabled = 0
" TODO: figure this out and synctex
let g:vimtex_syntax_enabled = 1
let g:vimtex_quickfix_open_on_warning = 0

" vim-tex-conceal {{{2
let g:tex_conceal = "abdgms"

" vim-cpp-enhanced-highlight {{{2
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_concepts_highlight = 1

" quick-scope {{{2
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
let g:qs_max_chars = 150

" vimwiki {{{2
let g:vimwiki_ext2syntax = {'.Rmd': 'markdown', '.rmd': 'markdown', '.md': 'markdown', '.markdown': 'markdown'}
let g:vimwiki_list = [{'path': '~/Documents/Notebooks/Vimwiki', 'syntax': 'markdown', 'ext': '.rmd'}]

" nerdtree/nerdtree-git-plugin/vim-nerdtree-syntax-highlight {{{2
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFoldersOpenClose = 1
let g:NERDTreeGitStatusNodeColorization = 1
let g:NERDTreeGitStatusWithFlags = 1
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : "☒",
    \ "Unknown"   : "?"
    \ }

" vim-fugitive

" vim-airline {{{2
let g:airline_powerline_fonts = 1
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_right_sep = ''
let g:airline#extensions#fugitiveline#enabled = 1
let g:airline#extensions#wordcount#enabled = 1
let g:airline#extensions#wordcount#filetypes = ['vimwiki', 'help', 'mail', 'markdown', 'tex', 'text', 'groff', 'rmarkdown']
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''
let g:airline#extensions#tabline#show_splits = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#coc#enabled = 1
let g:airline#extensions#coc#error_symbol = 'E:'
let g:airline#extensions#coc#warning_symbol = 'W:'

" vim-instant-markdown {{{2
let g:instant_markdown_autostart = 0

" vim-jsx-pretty {{{2
let g:vim_jsx_pretty_colorful_config = 1

" vim-closetag {{{2
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.js'
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx,*.js'
let g:closetag_filetypes = 'html,xhtml,phtml,js'
let g:closetag_xhtml_filetypes = 'xhtml,jsx,js'
let g:closetag_emptyTags_caseSensitive = 1
let g:closetag_regions = {
    \ 'typescript.tsx': 'jsxRegion,tsxRegion',
    \ 'javascript.jsx': 'jsxRegion',
    \ }
let g:closetag_shortcut = '>'
let g:closetag_close_shortcut = '<Leader>>'

" goyo.vim {{{2
let g:goyo_width = 120

" fzf.vim {{{2
let g:fzf_layout = { 'window': 'call CreateCenteredFloatingWindow()' }
let $FZF_DEFAULT_OPTS = "--reverse"
let g:fzf_action = {
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-s': 'split',
    \ 'ctrl-v': 'vsplit',
    \ 'ctrl-r': 'read'
    \ }

" ==================== MAPS ==================== {{{1
" Better tabbing
vnoremap < <gv
vnoremap > >gv

" Quick fzf commands {{{2
map <Leader>. :Files<CR>
map <Leader> :Maps<CR>,
map <Leader>m :Buffers<CR>

" Goyo modes {{{2
map <Leader>F :Goyo \| set bg=dark \| set linebreak<CR>

" Git status open in vertical split {{{2
command! GG :vertical G
cabbrev G GG

" Vim replacement for up and down {{{2
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

" Tmux compatibility {{{2
map <C-q> <C-a>

" Open file path from buffer in splits
" https://stackoverflow.com/questions/7672783/how-can-i-do-something-like-gf-but-in-a-new-vertical-split/7672839
map gs :above wincmd f<CR>
map gv :vertical wincmd f<CR>

" Toggle interface {{{2
map <Leader>l :call LocationToggle()<CR>
map <Leader>n :NERDTreeToggle<CR>

" Toggle spell check {{{2
map <Leader>o :setlocal spell! spelllang=en_us<CR>

" Split navigation shortcuts {{{2
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Run shell scripts {{{2
map <Leader>s :!clear && shellcheck %<CR>
map <Leader>c :w! \| !compiler "<c-r>%"<CR>
map <Leader>p :!opout "<c-r>%" &<CR><CR>
map <Leader>w :w !detex \| wc -w<CR>

" Navigating with guides {{{2
inoremap <Leader><Leader> <Esc>/<++><CR>"_c4l
vnoremap <Leader><Leader> <Esc>/<++><CR>"_c4l
map <Leader><Leader> <Esc>/<++><CR>"_c4l

" Show cursor {{{2
nmap + :set cursorline! cursorcolumn!<CR>

" Fix c
nnoremap c "_c

" Coc movements {{{2
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use <c-space> to trigger completion {{{2
inoremap <silent><expr> <c-space> coc#refresh()

" Symbol renaming {{{2
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code {{{2
xmap <leader>f <Plug>(coc-format-selected)
nmap <leader>f <Plug>(coc-format-selected)

" Applying codeAction to the selected region {{{2
xmap <leader>a <Plug>(coc-codeaction-selected)
nmap <leader>a <Plug>(coc-codeaction-selected)
nmap <leader>ac <Plug>(coc-codeaction)

" Apply AutoFix to problem on the current line {{{2
nmap <leader>x <Plug>(coc-fix-current)

" Coclist maps {{{2
nnoremap <silent> <space>a :<C-u>CocList diagnostics<cr>
nnoremap <silent> <space>e :<C-u>CocList extensions<cr>
nnoremap <silent> <space>c :<C-u>CocList commands<cr>
nnoremap <silent> <space>o :<C-u>CocList outline<cr>
nnoremap <silent> <space>s :<C-u>CocList -I symbols<cr>
nnoremap <silent> <space>j :<C-u>CocNext<CR>
nnoremap <silent> <space>k :<C-u>CocPrev<CR>
nnoremap <silent> <space>p :<C-u>CocListResume<CR>

" Replace K with coc doc {{{2
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Introduce function text object {{{2
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Templates {{{2
nmap <F2> :CocList templates<CR>

" Dictionary
nmap <F3> "dyiw:!osx-dictionary -d "American English" <C-r>d<CR>
nmap <F4> "dyiw:!osx-dictionary -d "American English Thesaurus" <C-r>d<CR>

" Limelight toggle
nmap <Leader>L :Limelight<CR>

" ==================== AUTOCMDS ==================== {{{1
" Clean tex junk on exit {{{2
autocmd VimLeave *.tex !texclear "%"

" Recognize files properly {{{2
autocmd BufRead,BufNewFile /tmp/calcurse*,~/.calcurse/notes/* set filetype=markdown
autocmd BufRead,BufNewFile *.ms,*.me,*.mom,*.man set filetype=groff
autocmd BufRead,BufNewFile *.tex set filetype=tex
autocmd BufRead,BufNewFile *.asm set syntax=nasm

" Deletes trailing whitespace on save {{{2
autocmd BufWritePre * %s/\s\+$//e

" Override neomutt textwidth setting
autocmd BufRead,BufNewFile neomutt-Franks-Mac* set textwidth=0

" Set tmux window name {{{2
autocmd BufReadPost,FileReadPost,BufNewFile,BufEnter * call system("tmux rename-window " . expand("%:t"))
autocmd VimLeave * call system("tmux setw automatic-rename")

" Close nerdtree on last window {{{2
autocmd Bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Disable auto commenting new lines {{{2
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Recognize comments in json {{{2
autocmd FileType json syntax match Comment +\/\/.\+$+

" Use limelight.vim automatically with goyo {{{2
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

" ==================== COMMANDS OR FUNCTIONS ==================== {{{1
" Fzf add preview {{{2
command! -bang -nargs=? -complete=dir Files call fzf#vim#files(<q-args>, {'options': ['--preview', 'preview {}']}, <bang>0)

" Fzf floating window {{{2
function! CreateCenteredFloatingWindow()
    let width = min([&columns - 4, max([80, &columns - 20])])
    let height = min([&lines - 4, max([20, &lines - 10])])
    let top = ((&lines - height) / 2) - 1
    let left = (&columns - width) / 2
    let opts = {'relative': 'editor', 'row': top, 'col': left, 'width': width, 'height': height, 'style': 'minimal'}
    let top = "╭" . repeat("─", width - 2) . "╮"
    let mid = "│" . repeat(" ", width - 2) . "│"
    let bot = "╰" . repeat("─", width - 2) . "╯"
    let lines = [top] + repeat([mid], height - 2) + [bot]
    let s:buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(s:buf, 0, -1, v:true, lines)
    call nvim_open_win(s:buf, v:true, opts)
    set winhl=Normal:Floating
    let opts.row += 1
    let opts.height -= 2
    let opts.col += 2
    let opts.width -= 4
    call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
    au BufWipeout <buffer> exe 'bw '.s:buf
endfunction

" Toggle location list {{{2
function! LocationToggle()
    if get(getloclist(0, {'winid':0}), 'winid', 0)
        lclose
    else
        lopen
    endif
endfunction

" Use K to show documentation in preview window {{{2
function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    elseif (index(['sh','zsh','bash','c','cpp'], &filetype) >= 0)
        execute 'Man '.expand('<cword>')
    else
        call CocAction('doHover')
    endif
endfunction

" Add `:Format` command to format current buffer {{{2
command! -nargs=0 Format :call CocAction('format')

" Add `:OR` command for organize imports of the current buffer {{{2
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')

" Word processor mode {{{2
" https://jasonheppler.org/2012/12/05/word-processor-mode-in-vim/
function! WordProcessorMode()
    setlocal formatoptions=t1
    setlocal textwidth=100
    map j gj
    map k gk
    setlocal smartindent
    setlocal spell spelllang=en_us
    setlocal noexpandtab
    nmap K "dyiw:!osx-dictionary -d "American English" <C-r>d<CR>
    nmap <Leader>t "dyiw:!osx-dictionary -d "American English Thesaurus" <C-r>d<CR>
    Goyo
endfunction
command! WP call WordProcessorMode()
