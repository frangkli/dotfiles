#!/bin/sh
# Profile file. Runs on login.

# PATH
export PATH="$PATH:/sbin"
export PATH="$PATH:/opt/local/bin:/opt/local/sbin"
export PATH="$PATH:/usr/local/sbin"
export PATH="$PATH:$(du "$HOME/.local/bin" | cut -f2 | tr '\n' ':' | sed 's/:*$//')"
export PATH="$PATH:$HOME/.gem/ruby/2.6.0/bin"
export PATH="$PATH:/Library/Frameworks/Python.framework/Versions/3.7/bin"
export PATH="$PATH:/usr/local/opt/gettext/bin:/usr/local/opt/openssl/bin:/usr/local/opt/ncurses/bin"
export PATH="$PATH:$(echo /usr/local/opt/{findutils,gnu-sed,gnu-indent,gnu-tar,grep,gawk,gnutls,gnu-getopt}/libexec/gnubin: | sed 's/ //g' | sed 's/.$//')"
export MANPATH="$MANPATH:$(echo /usr/local/opt/{findutils,gnu-sed,gnu-indent,gnu-tar,grep,gawk,gnutls,gnu-getopt}/libexec/gnuman: | sed 's/ //g' | sed 's/.$//')"
export GOPATH="$HOME/Programming/Go"
export NODE_PATH="$HOME/.local/share/node_modules"

# Personalization
export EDITOR="nvim"
export VISUAL="nvim"
export BROWSER="open"
export TERM="xterm-256color"
export READER="zathura --fork"
export SCHOOL="$HOME/OneDrive/School"
export BIB="$HOME/Documents/Bibliography"
export CLICOLOR=1
export HOMEBREW_NO_AUTO_UPDATE=1
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

# Vulkan config
export VULKAN_SDK="$HOME/.local/software/vulkansdk-macos-1.1.121.1/macOS"
export PATH="$PATH:$VULKAN_SDK/bin"
export DYLD_LIBRARY_PATH="$VULKAN_SDK/lib:$DYLD_LIBRARY_PATH"
export VK_ICD_FILENAMES="$VULKAN_SDK/etc/vulkan/icd.d/MoltenVK_icd.json"

# Python
export PYTHON_CONFIGURE_OPTS="--enable-framework"

# Openblas
export LDFLAGS="-L/usr/local/opt/openblas/lib"
export CPPFLAGS="-I/usr/local/opt/openblas/include"
export PKG_CONFIG_PATH="/usr/local/opt/openblas/lib/pkgconfig"

# Openssl
export LDFLAGS="$LDFLAGS -L/usr/local/opt/openssl/lib"
export CPPFLAGS="$CPPFLAGS -I/usr/local/opt/openssl/include"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/opt/openssl/lib/pkgconfig"

# C packages
export LDFLAGS="$LDFLAGS -L/usr/local/opt/libffi/lib"
export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:/usr/local/include"
export LIBRARY_PATH="$LIBRARY_PATH:/usr/local/lib"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/Cellar/cairo/1.16.0/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/X11/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/Homebrew/Library/Homebrew/os/mac/pkgconfig/10.15"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$(echo /usr/local/opt/*/lib/pkgconfig | sed 's/ /:/g')"

# Fuzzy finder config
export FZF_DEFAULT_COMMAND="ag --hidden --ignore .git -g ''"
export FZF_COMPLETION_TRIGGER="~~"

# Less/Man colors
export LESS=-R
export LESS_TERMCAP_md="$(printf '%b' '[1;31m')"; a="${a%_}"
export LESS_TERMCAP_me="$(printf '%b' '[1;36m')"; a="${a%_}"
export LESS_TERMCAP_mb="$(printf '%b' '[0m')"; a="${a%_}"
export LESS_TERMCAP_so="$(printf '%b' '[01;44;33m')"; a="${a%_}"
export LESS_TERMCAP_se="$(printf '%b' '[0m')"; a="${a%_}"
export LESS_TERMCAP_us="$(printf '%b' '[1;32m')"; a="${a%_}"
export LESS_TERMCAP_ue="$(printf '%b' '[0m')"; a="${a%_}"
# export LESSOPEN="|/usr/local/bin/lesspipe.sh %s"
# export LESS_ADVANCED_PREPROCESSOR=1

# Vi mode
set -o vi

# Z
[ -f "/usr/local/etc/profile.d/z.sh" ] && . "/usr/local/etc/profile.d/z.sh"

# Start up config
echo "Welcome, Frank Li"
