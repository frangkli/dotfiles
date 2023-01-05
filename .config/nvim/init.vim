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
Plug 'majutsushi/tagbar'

" Completion {{{3
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'metakirby5/codi.vim'
Plug 'rust-lang/rust.vim'

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
Plug 'airblade/vim-gitgutter'

" Color and highlights {{{3
Plug 'dylanaraps/wal.vim'
Plug 'ap/vim-css-color'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-context'
Plug 'luochen1990/rainbow'

" Web development {{{3
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
set signcolumn=yes                                      " Show signcolumn (left of line num) so text doesn't shift
set shortmess+=c                                        " Don't show completion log

" ==================== COLORS ==================== {{{1
colorscheme wal
highlight CursorLine ctermbg=9 cterm=none
highlight CursorColumn ctermbg=250 ctermfg=0
highlight CursorLineNr ctermfg=2
highlight WildMenu ctermfg=0 ctermbg=3
highlight Statusline ctermfg=7 ctermbg=none cterm=none
highlight QuickScopePrimary cterm=underline ctermfg=155
highlight QuickScopeSecondary cterm=underline ctermfg=81
highlight CocErrorFloat ctermfg=3
highlight Statement ctermfg=3
highlight Identifier cterm=none
highlight Conceal ctermbg=none
highlight vimUserCommand ctermfg=10
highlight htmlItalic cterm=italic ctermfg=5

" ==================== PLUGIN VARIABLES ===================== {{{1
" ultisnips {{{2
let g:UltiSnipsEditSplit = "normal"
let g:UltiSnipsExpandTrigger = "<S-Tab>"
let g:UltiSnipsJumpForwardTrigger = "<C-j>"
let g:UltiSnipsJumpBackwardTrigger = "<C-k>"

" rainbow {{{2
let g:rainbow_active = 1

" quick-scope {{{2
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
let g:qs_max_chars = 150

" nerdtree/nerdtree-git-plugin/vim-nerdtree-syntax-highlight {{{2
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFoldersOpenClose = 1
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeGitStatusNodeColorization = 1
let g:NERDTreeGitStatusWithFlags = 1
let g:NERDTreeGitStatusIndicatorMapCustom = {
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

" context.vim {{{2
let g:context_border_char = '-'

" fzf.vim {{{2
let $FZF_DEFAULT_OPTS = ""
let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'
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

" Open tag bar
nmap <Leader>t :TagbarToggle<CR>

" Reasonable Y
nnoremap Y y$

" Quick fzf commands {{{2
map <C-p> :Files<CR>
map <C-b> :Buffers<CR>
map <C-f> :Ag<CR>
map <Leader>cm :Commits<CR>
" map <Leader> :Maps<CR>,

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
map <Leader>l :CocDiagnostics<CR>
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
nmap <silent> <leader>gd <Plug>(coc-definition)
nmap <silent> <leader>gy <Plug>(coc-type-definition)
nmap <silent> <leader>gi <Plug>(coc-implementation)
nmap <silent> <leader>gr <Plug>(coc-references)

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

" Use tab and shift tab to navigate completion dropdown
inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"

" Replace K with coc doc {{{2
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Introduce function text object {{{2
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

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

" LaTeX auto iteming
autocmd BufRead,BufNewFile *.tex set comments+=b:\\item

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Make rainbow work
autocmd BufEnter * hi TSPunctBracket NONE
autocmd BufEnter * hi link TSPunctBracket nonexistenth

" ==================== COMMANDS OR FUNCTIONS ==================== {{{1
" Fzf add preview {{{2
command! -bang -nargs=? -complete=dir Files call fzf#vim#files(<q-args>, {'options': ['--preview', 'preview {}']}, <bang>0)

" Use K to show documentation in preview window {{{2
function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    elseif CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
    else
        call feedkeys('K', 'in')
    endif
endfunction

" Add `:Format` command to format current buffer {{{2
command! -nargs=0 Format :call CocAction('format')

" Add `:OR` command for organize imports of the current buffer {{{2
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')

" Preserve cursor position
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Regex align
command! -nargs=? -range Align <line1>,<line2>call AlignSection('<args>')
vnoremap <silent> A :Align<CR>
function! AlignSection(regex) range
    let extra = 1
    let sep = empty(a:regex) ? '=' : a:regex
    let maxpos = 0
    let section = getline(a:firstline, a:lastline)
    for line in section
        let pos = match(line, ' *'.sep)
        if maxpos < pos
            let maxpos = pos
        endif
    endfor
    call map(section, 'AlignLine(v:val, sep, maxpos, extra)')
    call setline(a:firstline, section)
endfunction

function! AlignLine(line, sep, maxpos, extra)
    let m = matchlist(a:line, '\(.\{-}\) \{-}\('.a:sep.'.*\)')
    if empty(m)
        return a:line
    endif
    let spaces = repeat(' ', a:maxpos - strlen(m[1]) + a:extra)
    return m[1] . spaces . m[2]
endfunction

" Use tab for trigger completion and navigate to the next complete item
function! CheckBackspace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <expr> <Tab>
    \ coc#pum#visible() ? coc#pum#next(1) :
    \ CheckBackspace() ? "\<Tab>" :
    \ coc#refresh()

" Nvim tree-sitter
lua << EOF
require'nvim-treesitter.configs'.setup {
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true,
    }
}
EOF
