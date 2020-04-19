#!/bin/sh
# Command path
export PATH="$PATH:/sbin"
export PATH="$PATH:/usr/local/sbin"
export PATH="$PATH:$HOME/.gem/ruby/2.6.0/bin"
export PATH="$PATH:/Library/Frameworks/Python.framework/Versions/3.7/bin"
export PATH="$PATH:/usr/local/opt/gettext/bin:/usr/local/opt/openssl/bin:/usr/local/opt/ncurses/bin"
export PATH="$PATH:/opt/local/bin:/opt/local/sbin"
export PATH="$PATH:$(du "$HOME/.local/bin" | cut -f2 | tr '\n' ':' | sed 's/:*$//')"
export PATH="$PATH:/usr/local/opt/llvm/bin"

# Replace mac BSD commands with GNU
export PATH="$(echo /usr/local/opt/{coreutils,findutils,gnu-sed,gnu-indent,gnu-tar,grep,gawk,gnutls,gnu-getopt}/libexec/gnubin: | sed 's/ //g' | sed 's/.$//'):$PATH"
export MANPATH="$(echo /usr/local/opt/{findutils,gnu-sed,gnu-indent,gnu-tar,grep,gawk,gnutls,gnu-getopt}/libexec/gnuman: | sed 's/ //g' | sed 's/.$//'):$MANPATH"

# Personalize env
export EDITOR="nvim"
export VISUAL="nvim"
export BROWSER="open"
export TERM="st-256color"
export READER="dothura"
export BIB="$HOME/Documents/Bibliography"
export CLICOLOR=1
export HOMEBREW_NO_AUTO_UPDATE=1
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
export WWW_HOME="$XDG_CONFIG_HOME/w3m"
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

# Vulkan config
export VULKAN_SDK="$HOME/.local/software/vulkansdk-macos-1.1.121.1/macOS"
export PATH="$PATH:$VULKAN_SDK/bin"
export DYLD_LIBRARY_PATH="$VULKAN_SDK/lib:$DYLD_LIBRARY_PATH"
export VK_ICD_FILENAMES="$VULKAN_SDK/etc/vulkan/icd.d/MoltenVK_icd.json"

# Python configs
export PYTHON_CONFIGURE_OPTS="--enable-framework"

# Openblas
export LDFLAGS="-L/usr/local/opt/openblas/lib"
export CPPFLAGS="-I/usr/local/opt/openblas/include"
export PKG_CONFIG_PATH="/usr/local/opt/openblas/lib/pkgconfig"

# Openssl
export LDFLAGS="$LDFLAGS -L/usr/local/opt/openssl/lib"
export CPPFLAGS="$CPPFLAGS -I/usr/local/opt/openssl/include"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/opt/openssl/lib/pkgconfig"

# Llvm
export LDFLAGS="$LDFLAGS -L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib"
export CPPFLAGS="$CPPFLAGS -I/usr/local/opt/llvm/include -I/usr/local/opt/llvm/include/c++/v1/"

# C packages path
export LDFLAGS="$LDFLAGS -L/usr/local/opt/libffi/lib"
export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:/usr/local/include"
export LIBRARY_PATH="$LIBRARY_PATH:/usr/local/lib"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/Cellar/cairo/1.16.0/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/X11/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/Homebrew/Library/Homebrew/os/mac/pkgconfig/10.15"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$(echo /usr/local/opt/*/lib/pkgconfig | sed 's/ /:/g')"

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
. "/Users/frank/.local/bin/info/shellstart"
