let mapleader =","

if ! filereadable(expand('~/.config/nvim/autoload/plug.vim'))
	echo "Downloading junegunn/vim-plug to manage plugins..."
	silent !mkdir -p ~/.config/nvim/autoload/
	silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ~/.config/nvim/autoload/plug.vim
endif

call plug#begin('~/.config/nvim/plugged')
" Plug 'LukeSmithxyz/vimling'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'ryanoasis/vim-devicons'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/goyo.vim'
Plug 'Yggdroot/indentLine'
Plug 'vimwiki/vimwiki'
Plug 'bling/vim-airline'
Plug 'lervag/vimtex', { 'for': ['tex', 'bib'] }
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'dylanaraps/wal.vim'
Plug 'octol/vim-cpp-enhanced-highlight', { 'for': ['c', 'cpp'] }
Plug 'suan/vim-instant-markdown', { 'for': 'markdown' }
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'ervandew/supertab'
Plug 'jiangmiao/auto-pairs'
Plug 'pangloss/vim-javascript', { 'for': ['javascript', 'jsx', 'javascriptreact'] }
Plug 'maxmellon/vim-jsx-pretty', { 'for': ['javascript', 'jsx', 'javascriptreact'] }
Plug 'alvan/vim-closetag', { 'for': ['javascript', 'jsx', 'javascriptreact', 'html'] }
Plug 'Valloric/YouCompleteMe', { 'do':'./install.py', 'for': ['python', 'c', 'javascript', 'jsx', 'javascriptreact', 'java', 'cpp', 'vim', 'tex'] }
Plug 'majutsushi/tagbar', { 'for': ['c', 'cpp', 'python', 'javascript', 'jsx', 'java', 'javascriptreact'] }
" Plug 'scrooloose/syntastic', { 'for': ['python'] }
call plug#end()

set bg=light
set go=a
set mouse=a
set exrc
set hlsearch
set expandtab
set clipboard=unnamedplus
set undodir=~/.config/nvim/undodir
set undofile
set encoding=utf-8
set number relativenumber
set fillchars=vert:\│
set tabstop=4
set shiftwidth=4
nnoremap c "_c
filetype plugin on
syntax on

" Vimwiki fix override
nmap <Leader>wn <Plug>VimwikiNextLink

" Indent line styling
let g:indentLine_char_list = ['|', '¦', '┆', '┊']

" Nerd tree styling
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
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }

" Replacement for up and down arrow
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

" Highlight colors:
color wal
highlight CursorLineNr ctermfg=2

" Fzf
command! -bang -nargs=? -complete=dir Files call fzf#vim#files(<q-args>, {'options': ['--preview', 'preview {}']}, <bang>0)
let g:fzf_layout = { 'window': 'call CreateCenteredFloatingWindow()' }
let $FZF_DEFAULT_OPTS="--reverse " " top to bottom
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit',
  \ 'ctrl-r': 'read'
  \ }
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

" Files + devicons + floating fzf
function! Fzf_dev()
    let l:fzf_files_options = '--preview "bat --theme="OneHalfDark" --style=numbers,changes --color always {2..-1} | head -'.&lines.'"'
    function! s:files()
        let l:files = split(system($FZF_DEFAULT_COMMAND), '\n')
        return s:prepend_icon(l:files)
    endfunction

    function! s:prepend_icon(candidates)
        let l:result = []
        for l:candidate in a:candidates
            let l:filename = fnamemodify(l:candidate, ':p:t')
            let l:icon = WebDevIconsGetFileTypeSymbol(l:filename, isdirectory(l:filename))
            call add(l:result, printf('%s %s', l:icon, l:candidate))
        endfor
        return l:result
    endfunction

    function! s:edit_file(item)
        let l:pos = stridx(a:item, ' ')
        let l:file_path = a:item[pos+1:-1]
        execute 'silent e' l:file_path
    endfunction

    call fzf#run({
        \ 'source': <sid>files(),
        \ 'sink':   function('s:edit_file'),
        \ 'options': '-m --reverse ' . l:fzf_files_options,
        \ 'down':    '40%',
        \ 'window': 'call CreateCenteredFloatingWindow()'})
endfunction

" Tagbar
let g:tagbar_autofocus = 1
nmap ,tt :TagbarToggle<CR>

" Tmux compatibility
map <C-q> <C-a>
autocmd BufReadPost,FileReadPost,BufNewFile,BufEnter * call system("tmux rename-window " . expand("%:t"))
autocmd VimLeave * call system("tmux setw automatic-rename")

" Enable folding
set foldmethod=indent
set foldlevel=99

" Syntastic config
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1
let g:syntastic_error_symbol = "✗"
let g:syntastic_warning_symbol = "⚠"
highlight SyntasticErrorSign ctermfg=12 ctermbg=0
highlight SyntasticWarningSign ctermfg=14 ctermbg=0

" Cursor precision:
highlight CursorLine ctermbg=9
highlight CursorColumn ctermbg=9
nmap + :set cursorline! cursorcolumn!<CR>

" Airline config:
let g:airline_powerline_fonts=1
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_right_sep = ''
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#ycm#enabled = 1
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#fugitiveline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''
let g:airline#extensions#tabline#show_splits = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#ycm#error_symbol = 'Error:'
let g:airline#extensions#ycm#warning_symbol = 'Warning:'

" Youcompleteme config:
let g:ycm_global_ycm_extra_conf = '$HOME/.config/nvim/plugged/YouCompleteMe/third_party/ycmd/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf = 0
let g:ycm_semantic_triggers =  {
    \   'c': ['->', '.', 're!\w{2}'],
    \   'objc': ['->', '.', 're!\[[_a-zA-Z]+\w*\s', 're!^\s*[^\W\d]\w*\s', 're!\[.*\]\s'],
    \   'ocaml': ['.', '#'],
    \   'cpp,cuda,objcpp': ['->', '.', '::', 're!\w{2}'],
    \   'perl': ['->'],
    \   'php': ['->', '::'],
    \   'cs,d,elixir,go,groovy,java,javascript,julia,perl6,scala,typescript,vb': ['.'],
    \   'ruby,rust': ['.', '::'],
    \   'lua': ['.', ':'],
    \   'erlang': [':'],
    \   'python': ['.', 're!\w{2}'],
    \ }
let g:ycm_python_binary_path = 'python3'
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_add_preview_to_completeopt = 1
set completeopt-=preview
map yd :YcmCompleter GetDoc<CR>
map <leader>d :YcmCompleter GoToDefinition<CR>
map <leader>g :YcmCompleter GoTo<CR>
map <leader>x :YcmCompleter FixIt<CR>
map <leader>l Hmx``:lopen<CR>
map <leader>L :lclose<CR><C-w>k`xzt``
" map <leader>l :lopen<CR>
" map <leader>L :lclose<CR>
highlight Pmenu ctermbg=darkgray ctermfg=black

" Instant markdown preview config:
let g:instant_markdown_autostart = 0

" Vim jsx pretty config:
let g:vim_jsx_pretty_colorful_config = 1

" Autoclosetag config:
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.js'
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx,*.js'
let g:closetag_filetypes = 'html,xhtml,phtml'
let g:closetag_xhtml_filetypes = 'xhtml,jsx,js'
let g:closetag_emptyTags_caseSensitive = 1
let g:closetag_regions = {
    \ 'typescript.tsx': 'jsxRegion,tsxRegion',
    \ 'javascript.jsx': 'jsxRegion',
    \ }
let g:closetag_shortcut = '>'
let g:closetag_close_shortcut = '<leader>>'

" Warn when more than 100 columns:
call matchadd('ColorColumn', '\%100v', 100)

" Enable autocompletion:
set wildmode=longest,list,full

" Word count
map <leader>w :w !detex \| wc -w<CR>

" Fzf configuration:
map <leader>. :Files<CR>
map <leader> :Maps<CR>,
map <leader>m :Buffers<CR>

" Disables automatic commenting on newline:
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Goyo plugin makes text more readable when writing prose:
let g:goyo_width=90
map <leader>F :Goyo \| set bg=dark \| set linebreak<CR>

" Reading environment
map <leader>R :Goyo \| set bg=dark \| set linebreak \| set so=999 \| set cursorline!<CR>

" Spell-check set to <leader>o, 'o' for 'orthography':
map <leader>o :setlocal spell! spelllang=en_us<CR>

" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
set splitbelow splitright

" Nerd tree
map <C-n> :NERDTreeToggle<CR>
autocmd Bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Cpp highlight
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_concepts_highlight = 1

" Vimling binding:
" nmap <leader>D :call ToggleDeadKeys()<CR>
" imap <leader>D <esc>:call ToggleDeadKeys()<CR>a
" nmap <leader>i :call ToggleIPA()<CR>
" imap <leader>i <esc>:call ToggleIPA()<CR>a
" nmap <leader>q :call ToggleProse()<CR>

" Shortcutting split navigation, saving a keypress:
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Check file in shellcheck:
map <leader>s :!clear && shellcheck %<CR>

" Open my bibliography file in split
"map <leader>b :vsp<space>$BIB<CR>
"map <leader>r :vsp<space>$REFER<CR>

" Replace all is aliased to S.
nnoremap S :%s//g<Left><Left>

" Compiler script
map <leader>c :w! \| !compiler "<c-r>%"<CR>

" Open corresponding .pdf/.html or preview
map <leader>p :!opout "<c-r>%"<CR><CR>

" Runs a script that cleans out tex build files whenever I close out of a .tex file.
autocmd VimLeave *.tex !texclear %

" Ensure files are read as what I want:
let g:vimwiki_ext2syntax = {'.Rmd': 'markdown', '.rmd': 'markdown', '.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
let g:vimwiki_list = [{'path': '~/Documents/Notebooks/Vimwiki', 'syntax': 'markdown', 'ext': '.rmd'}]
autocmd BufRead,BufNewFile /tmp/calcurse*,~/.calcurse/notes/* set filetype=markdown
autocmd BufRead,BufNewFile *.ms,*.me,*.mom,*.man set filetype=groff
autocmd BufRead,BufNewFile *.tex set filetype=tex
autocmd BufRead,BufNewFile *.asm set syntax=nasm

" Copy selected text to system clipboard (requires gvim/nvim/vim-x11 installed):
vnoremap <C-c> "+y
map <C-p> "+P

" Automatically deletes all trailing whitespace on save.
autocmd BufWritePre * %s/\s\+$//e

" Navigating with guides
inoremap <leader><leader> <Esc>/<++><CR>"_c4l
vnoremap <leader><leader> <Esc>/<++><CR>"_c4l
map <leader><leader> <Esc>/<++><CR>"_c4l

" Import LaTeX config if file is tex
autocmd FileType tex source ~/.config/nvim/mylatex.vim

" Import HTML config if file is html
autocmd FileType html source ~/.config/nvim/myhtml.vim

" Import markdown config if file is md
autocmd FileType markdown,rmd source ~/.config/nvim/mymarkdown.vim

""".bib
autocmd FileType bib source ~/.config/nvim/mybib.vim
