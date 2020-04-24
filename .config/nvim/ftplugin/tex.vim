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
command! -bang Templates call fzf#vim#files('~/Documents/Document-Templates/LaTeX', <bang>0)
map <F2> :Templates<CR>

" Automatically enter stuff {{{2
function CR()
    if searchpair('\\begin{itemize}', '', '\\end{itemize}', '') || searchpair('\\begin{enumerate}', '', '\\end{enumerate}', '')
        return "\r\\item "
    elseif searchpair('\\begin{description}', '', '\\end{description}', '')
        return "\r\\item[] <++>\eF]i"
    elseif searchpair('\\begin{align}', '', '\\end{align}', '') || searchpair('\\begin{align\*}', '', '\\end{align\*}', '')
        return " \\\\\r"
    endif
    return "\r"
endfunction
inoremap <expr><buffer> <CR> CR()

" Code snippets {{{2
inoremap ,em \emph{}<++><Esc>T{i
inoremap ,bf \textbf{}<++><Esc>T{i
inoremap ,it \textit{}<++><Esc>T{i
inoremap ,un \underline{}<++><Esc>T{i
inoremap ,ft \footnote{}<++><Esc>T{i
inoremap ,ce \ce{}<++><Esc>T{i
inoremap "" ``''<++><Esc>T`i
inoremap ,si \si{}<++><Esc>F}i
inoremap ,SI \SI{}{<++>}<++><Esc>2F}i
inoremap ,pb \pagebreak<CR>
