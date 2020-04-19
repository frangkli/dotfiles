#!/bin/zsh
# Basic colors
TERM=xterm-256color
autoload -Uz colors && colors

# Zsh completion config
# $ man zshcompsys
autoload -Uz compinit
zstyle ':completion:*' menu select              # allow selection menu
zstyle ':completion:*' list-colors ''           # color menu items
zstyle ':completion:*' special-dirs true        # show dot files and folders
zstyle ':completion:*' group-name ''            # don't group menu items

# Better killall completion
zstyle ':completion:*:killall:*' command 'ps -u $USER -o cmd'

# Complete case-insensitive, partial-word, and then substring
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Ignore certain file extension for each program
# https://www.reddit.com/r/zsh/comments/5ghouo/is_there_a_way_to_have_zsh_ignore_certain_file/
# http://zsh.sourceforge.net/Doc/Release/Expansion.html#Glob-Operators
zstyle ':completion:*:*:dothura:*' file-patterns '*.pdf:source-files' '*:all-files'
zstyle ':completion:*:*:zathura:*' file-patterns '*.pdf:source-files' '*:all-files'
zstyle ':completion:*:*:nvim:*' file-patterns '^*.(pdf|o|png|jpg|jpeg|gif):source-files' '*:all-files'

# Launch compinit
zmodload zsh/complist
compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION
_comp_options+=(globdots) # Show dotfiles

# TODO: find out the difference and purpose of bashcompinit and compinit
autoload -U +X bashcompinit && bashcompinit

# Show dots if tab completion is taking long to load (removed due to flickering)
# https://github.com/gotbletu/dotfiles/blob/master/zshrc/.zshrc
# expand-or-complete-with-dots() {
#     echo -n "\e[31m......\e[0m"
#     zle expand-or-complete
#     zle redisplay
# }
# zle -N expand-or-complete-with-dots
# bindkey "^I" expand-or-complete-with-dots

# Vcs for git prompt info
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn hg
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' formats "[%{$fg[blue]%}%b%{$reset_color%}] (%{$fg[yellow]%}%c%{$fg[green]%}%u%{$reset_color%}) %{$fg[yellow]%}%s%{$fg[blue]%}:%r%{$reset_color%}"

# Commands to run before each prompt
function precmd() {
    vcs_info
    window_title="\033]0;$(pwd | sed 's/\/Users\/frank/~/; s/OneDrive - Yew Chung International School HK/OneDrive/') - $(echo /usr/local/bin/zsh | rev | cut -d '/' -f 1 | rev | awk '{ print toupper($0) }')\007"
    echo -ne "$window_title"
}

# Vim commandline mode config
# TODO: make rprompt show visual mode as well
bindkey -v
export KEYTIMEOUT=1
vim_ins_mode="%{$fg[yellow]%}[INS]%{$reset_color%}"
vim_cmd_mode="%{$fg[cyan]%}[NOR]%{$reset_color%}"
# vim_vis_mode="%{$fg[red]%}[VIS]%{$reset_color%}"
vim_mode=$vim_ins_mode
function zle-line-init zle-keymap-select {
    case ${KEYMAP} in
        (vicmd) vim_mode=$vim_cmd_mode && echo -ne '\e[1 q' ;;
        (main|viins) vim_mode=$vim_ins_mode && echo -ne '\e[5 q' ;;
        # (visual|viopp) vim_mode=$vim_vis_mode ;;
    esac
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# Use beam shape cursor
echo -ne '\e[5 q'
preexec() { echo -ne '\e[5 q' ;}

# Vim keys in tab complete menu
bindkey -M menuselect "h" vi-backward-char
bindkey -M menuselect "k" vi-up-line-or-history
bindkey -M menuselect "l" vi-forward-char
bindkey -M menuselect "j" vi-down-line-or-history
bindkey -v "^?" backward-delete-char

# Vim bindings in quotations
autoload -U select-quoted
zle -N select-quoted
for m in visual viopp; do
    for c in {a,i}{\',\",\`}; do
        bindkey -M $m $c select-quoted
    done
done

# Vim bindings in brackets
autoload -U select-bracketed
zle -N select-bracketed
for m in visual viopp; do
    for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
        bindkey -M $m $c select-bracketed
    done
done

# Edit command in vim
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^E" edit-command-line

# History search in vim
bindkey -M viins "^B" history-incremental-search-backward
bindkey -M vicmd "^B" history-incremental-search-backward

# Prompt styling
setopt PROMPT_SUBST
PROMPT="%(?.%F{green}%?.%F{red}%?)%F{black}-%F{red}%B[%b%F{yellow}%n%F{green}@%F{blue}%M:%F{magenta}%c%F{red}%B]%f%#%b "
RPROMPT='${vim_mode} ${vcs_info_msg_0_}'

# Expand aliases to actual commands
function expand-alias() {
    zle _expand_alias
    zle self-insert
}
zle -N expand-alias
bindkey -M main ' ' expand-alias # show actual command by entering space after alias

# History file
setopt APPEND_HISTORY           # add session history instead of replace
setopt EXTENDED_HISTORY         # more info in history file
setopt HIST_FIND_NO_DUPS        # don't show duplicate commands when finding
setopt HIST_IGNORE_DUPS         # don't record in history is command same as previous
setopt HIST_IGNORE_SPACE        # allow private commands with space prefix
setopt HIST_EXPIRE_DUPS_FIRST   # expire duplicate commands first
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.config/zsh/history

# Movement enhancement
setopt AUTO_CD # automatically cd when directory path entered
setopt AUTO_PUSHD # pushd after cd

# Quick bindings
bindkey -s "^o" "lfcd\n"

# Pip completion
function _pip_completion {
    local words cword
    read -Ac words
    read -cn cword
    reply=( $( COMP_WORDS="$words[*]" \
        COMP_CWORD=$(( cword-1 )) \
        PIP_AUTO_COMPLETE=1 $words[1] ) )
}
compctl -K _pip_completion pip3

# Source files
[ -f "$HOME/.config/zsh/.zprofile" ] && . "$HOME/.config/zsh/.zprofile"
[ -f "$HOME/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh" ] && . "$HOME/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
[ -f "$HOME/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh" ] && . "$HOME/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
[ -f "$HOME/.config/aliasrc" ] && . "$HOME/.config/aliasrc"
[ -f "$HOME/.config/shortcutrc" ] && . "$HOME/.config/shortcutrc"
[ -f "/usr/local/etc/profile.d/z.sh" ] && . "/usr/local/etc/profile.d/z.sh"

# Alias overwrite
alias repr="source $HOME/.config/zsh/.zshrc"

# Prompt syntax highlight
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=cyan' # e.g. -option
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=cyan' # e.g. --option
ZSH_HIGHLIGHT_STYLES[redirection]='fg=red,underline' # e.g. >>, >

# Miniconda3
__conda_setup="$('/Users/frank/Miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/frank/Miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/frank/Miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/frank/Miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# iTerm integration
test -e "${ZDOTDIR}/.iterm2_shell_integration.zsh" && source "${ZDOTDIR}/.iterm2_shell_integration.zsh"
