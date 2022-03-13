#!/bin/sh
# Command path
export PATH="$PATH:/sbin"
export PATH="$PATH:/usr/local/sbin"
export PATH="$PATH:/opt/local/bin:/opt/local/sbin"
export PATH="$PATH:$(du "$HOME/.local/bin" | cut -f2 | tr '\n' ':' | sed 's/:*$//')"

# Personalize env
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export BROWSER="open"
export CLICOLOR=1
export LANG="en_US"
export LC_ALL="en_US.UTF-8"

# Clean up
export XML_CATALOG_FILES="/usr/local/etc/xml/catalog"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export LPASS_HOME="$XDG_CONFIG_HOME/lpass"
export _Z_DATA="$XDG_DATA_HOME/z/z"
export TASKRC="$XDG_CONFIG_HOME/task/taskrc"
export HISTFILE="$XDG_CONFIG_HOME/zsh/history"
export LESSHISTFILE="-"
#export WWW_HOME="$XDG_CONFIG_HOME/w3m"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export PASSWORD_STORE_DIR="$XDG_CONFIG_HOME/password-store"
export STARDICT_DATA_DIR="$HOME/Documents/Dictionaries"
export NOTMUCH_CONFIG="$XDG_CONFIG_HOME/notmuch-config"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export GEM_HOME="$XDG_DATA_HOME/gem"
export GEM_SPEC_CACHE="$XDG_CACHE_HOME/gem"
export CONDA_PREFIX="$XDG_CONFIG_HOME/conda"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc" # node-gyp in XDG_DATA_HOME
export SQLITE_HISTORY="$XDG_DATA_HOME/sqlite_history"
export TERMINFO="$XDG_DATA_HOME/terminfo"
export TERMINFO_DIRS="$XDG_DATA_HOME/terminfo:/usr/share/terminfo"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export CONAN_USER_HOME="$XDG_DATA_HOME"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export PYLINTHOME="$XDG_CACHE_HOME/pylint"

# Python configs
export PYTHON_CONFIGURE_OPTS="--enable-framework"

# Other path variables
export GOPATH="$HOME/Programming/Go"
export NODE_PATH="$HOME/.local/share/node_modules"

# Fuzzy finder config
export FZF_DEFAULT_COMMAND="ag --hidden --ignore .git -g ''"
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
--color=dark
--color=fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f
--color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
'
export FZF_COMPLETION_TRIGGER="~~"

# Less/Man colors
export LESS=-R
export LESS_TERMCAP_mb=$'\E[01;32m'     # begin blinking
export LESS_TERMCAP_md=$'\E[01;32m'     # begin bold
export LESS_TERMCAP_me=$'\E[0m'         # end mode
export LESS_TERMCAP_se=$'\E[0m'         # end standout-mode
export LESS_TERMCAP_so=$'\E[01;44;33m'  # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'         # end underline
export LESS_TERMCAP_us=$'\E[01;31m'     # begin underline
export LESSOPEN="|/usr/local/bin/lesspipe.sh %s"
export LESS_ADVANCED_PREPROCESSOR=1

# Lf icons
export LF_ICONS="\
di=:\
fi=:\
ln=:\
or=:\
ex=:\
*.c=:\
*.cc=:\
*.clj=:\
*.coffee=:\
*.cpp=:\
*.css=:\
*.sass=:\
*.d=:\
*.dart=:\
*.erl=:\
*.exs=:\
*.fs=:\
*.go=:\
*.h=:\
*.hh=:\
*.hpp=:\
*.hs=:\
*.html=:\
*.java=:\
*.jl=:\
*.js=:\
*.json=:\
*.lua=:\
*.md=:\
*.rmd=:\
*.php=:\
*.pl=:\
*.pro=:\
*.py=:\
*.ipynb=:\
*.rb=:\
*.rs=:\
*.scala=:\
*.ts=:\
*.vim=:\
*.cmd=:\
*.ps1=:\
*.sh=:\
*.bash=:\
*.zsh=:\
*.fish=:\
*.tar=:\
*.tgz=:\
*.arc=:\
*.arj=:\
*.taz=:\
*.lha=:\
*.lz4=:\
*.lzh=:\
*.lzma=:\
*.tlz=:\
*.txz=:\
*.tzo=:\
*.t7z=:\
*.zip=:\
*.z=:\
*.dz=:\
*.gz=:\
*.lrz=:\
*.lz=:\
*.lzo=:\
*.xz=:\
*.zst=:\
*.tzst=:\
*.bz2=:\
*.bz=:\
*.tbz=:\
*.tbz2=:\
*.tz=:\
*.deb=:\
*.rpm=:\
*.jar=:\
*.war=:\
*.ear=:\
*.sar=:\
*.rar=:\
*.alz=:\
*.ace=:\
*.zoo=:\
*.cpio=:\
*.7z=:\
*.rz=:\
*.cab=:\
*.wim=:\
*.swm=:\
*.dwm=:\
*.esd=:\
*.jpg=:\
*.JPG=:\
*.jpeg=:\
*.mjpg=:\
*.mjpeg=:\
*.gif=:\
*.bmp=:\
*.pbm=:\
*.pgm=:\
*.ppm=:\
*.tga=:\
*.xbm=:\
*.xpm=:\
*.tif=:\
*.tiff=:\
*.png=:\
*.svg=:\
*.svgz=:\
*.mng=:\
*.pcx=:\
*.mov=:\
*.mpg=:\
*.mpeg=:\
*.m2v=:\
*.mkv=:\
*.webm=:\
*.ogm=:\
*.mp4=:\
*.m4v=:\
*.mp4v=:\
*.vob=:\
*.qt=:\
*.nuv=:\
*.wmv=:\
*.asf=:\
*.rm=:\
*.rmvb=:\
*.flc=:\
*.avi=:\
*.fli=:\
*.flv=:\
*.gl=:\
*.dl=:\
*.xcf=:\
*.xwd=:\
*.yuv=:\
*.cgm=:\
*.emf=:\
*.ogv=:\
*.ogx=:\
*.aac=:\
*.au=:\
*.flac=:\
*.m4a=:\
*.mid=:\
*.midi=:\
*.mka=:\
*.mp3=:\
*.mpc=:\
*.ogg=:\
*.ra=:\
*.wav=:\
*.oga=:\
*.opus=:\
*.spx=:\
*.xspf=:\
*.pdf=:\
*.nix=:\
*.db=:\
*.ppt=:\
*.pptx=:\
*.doc=:\
*.docx=:\
*.txt=:\
*.tex=:\
*.bib=:\
"

# Vi mode
set -o vi

# Start up script
shellstart

# Rust startup
. "$HOME/.cargo/env"
