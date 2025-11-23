# set -x

# shortcut to this dotfiles path is $DOTFILES
export DOTFILES="${HOME}/.dotfiles"

# your project folder that we can `c [tab]` to
export PROJECTS="${HOME}/Code"

# your default editor
export EDITOR='vim'
export VEDITOR='code'
export VISUAL='code'

export REPORTTIME=10

# export CFLAGS for pycrypto
CFLAGS="-I/usr/local/include -L/usr/local/lib"
export CFLAGS

# export GPG_TTY for gpg
export GPG_TTY=$(tty)

# python related exports
export PYTHONPYCACHEPREFIX='/tmp/'

export PYTHON_CONFIGURE_OPTS="--enable-framework"

# Python startup script for better python interpreter
export PYTHONSTARTUP=${HOME}/.pythonrc

# home dir local path exports
export PATH="/opt/homebrew/sbin:/opt/homebrew/bin:/usr/local/sbin:${HOME}/.local/bin:$PATH"

# gem path for local user
export PATH="/opt/homebrew/opt/ruby/bin":$PATH
if [[ $(command -v ruby) == "/opt/homebrew/opt/ruby/bin/ruby" ]]; then
    export PATH="/opt/homebrew/lib/ruby/gems/3.3.0/bin":$PATH
    export CFLAGS="-I/opt/homebrew/lib/ruby/gems/3.3.0/gems/"
fi

# remove local errors
export LC_ALL="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_TERMINAL="iTerm2"

# export heroku cli path
export PATH="/usr/local/opt/heroku-node/bin:$PATH"

export PUB_HOSTED_URL="https://pub.dev/"

# need nextflow in path
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export JAVA_CMD=/opt/homebrew/opt/openjdk/bin/java

# export default profile for AWS
export AWS_PROFILE="No AWS"

## export GOPATH for go lang package library path
export GOPATH=${HOME}/.golib
if ! [[ -e "${HOME}/.golib" ]]; then
    mkdir -p "${HOME}/.golib"
    go install -v golang.org/x/tools/gopls@latest
    go install -v github.com/uudashr/gopkgs/v2/cmd/gopkgs@latest
    go install -v github.com/ramya-rao-a/go-outline@latest
    go install -v github.com/go-delve/delve/cmd/dlv@latest
    go install -v github.com/go-delve/delve/cmd/dlv@master@latest
    go install -v honnef.co/go/tools/cmd/staticcheck@latest
fi

## export GOPATH to system PATH
export PATH=$PATH:$GOPATH/bin

## export main go user source path
export GOPATH=$GOPATH:${HOME}/Developer/practiceGo

export ZSH_COMPDUMP_DIR="${HOME}/.cache/zsh"
if ! [[ -d "${ZSH_COMPDUMP_DIR}" ]]; then
    mkdir -p "${ZSH_COMPDUMP_DIR}"
fi
export ZSH_COMPDUMP="$ZSH_COMPDUMP_DIR/.zcompdump"

# export npm global install packages
NPM_CONFIG_PREFIX=${HOME}/.npm-global
mkdir -p ${NPM_CONFIG_PREFIX}
export NPM_CONFIG_PREFIX

# export GPG TTY
export GPG_TTY=$(tty)

# set ZDOTDIR to tmp
export ZDOTDIR=${HOME}
export ZSH_COMPDUMP=/tmp/.zcompdump-${USER}-${HOST}

export HISTFILE=/Users/narender/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

# export XDG_CONFIG_HOME default to ~/.config
export XDG_CONFIG_HOME=${HOME}/.config/

# set starship config location
export STARSHIP_CONFIG=${XDG_CONFIG_HOME}/starship/starship.toml
