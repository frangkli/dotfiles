" ==================== SETTINGS ==================== {{{1
" Basic tex {{{2
let maplocalleader = ","
let g:tex_indent_items = 1
let g:tex_indent_and = 1
let g:tex_indent_brace = 1
let g:tex_flavor = 'latex'

" ==================== MAPS AND COMMANDS ==================== {{{1
" Vimtex map {{{2
map <Leader>t :VimtexTocToggle<CR>
map <Leader>c :VimtexCompile<CR>
map <leader>w :VimtexCountWords<CR>

" Templates commands {{{2
" Replaced with CocList
"command! -bang Templates call fzf#vim#files('~/Documents/Document-Templates/LaTeX', <bang>0)
"map <F2> :Templates<CR>

" Automatically enter stuff {{{2
set formatoptions=tcroqln
function CR()
    if getline('.') =~ '\\\\$' && (searchpair('\\begin{itemize}', '', '\\end{itemize}', '') || searchpair('\\begin{enumerate}', '', '\\end{enumerate}', ''))
        return "\r\eddkA\b\b\r\b\b\b\b\b\b\r"
    elseif getline('.') =~ '^\s*$' && (searchpair('\\begin{itemize}', '', '\\end{itemize}', '') || searchpair('\\begin{enumerate}', '', '\\end{enumerate}', ''))
        return "\b\\item "
    elseif getline('.') !~ '\\item' && getline('.') !~ '\.$' && (searchpair('\\begin{itemize}', '', '\\end{itemize}', '') || searchpair('\\begin{enumerate}', '', '\\end{enumerate}', ''))
        return " \\\\\r"
    elseif searchpair('\\begin{description}', '', '\\end{description}', '')
        return "\r\\item[] <++>\eF]i"
    elseif searchpair('\\begin{align}', '', '\\end{align}', '') || searchpair('\\begin{align\*}', '', '\\end{align\*}', '')
        return " \\\\\r"
    endif
    return "\r"
endfunction
inoremap <expr><buffer> <CR> getline('.') =~ '\item $' ? '<Esc>ddkA\\<CR><C-W><C-W><Tab>' : CR()

" Code snippets {{{2
inoremap ,em \emph{}<++><Esc>T{i
inoremap ,b \textbf{}<++><Esc>T{i
inoremap ,i \textit{}<++><Esc>T{i
inoremap ,un \underline{}<++><Esc>T{i
inoremap ,ft \footnote{}<++><Esc>T{i
inoremap ,ce \ce{}<++><Esc>T{i
inoremap "" ``''<++><Esc>T`i
inoremap ,si \si{}<++><Esc>F}i
inoremap ,SI \SI{}{<++>}<++><Esc>2F}i
inoremap ,pb \pagebreak<CR>
inoremap ,l <CR>\item <Esc>A
