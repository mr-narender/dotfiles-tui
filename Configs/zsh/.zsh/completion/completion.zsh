#!/usr/bin/env bash

# forces zsh to realize new commands
zstyle ':completion:*' completer _oldlist _expand _complete _match _ignored _approximate

# matches case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

# rehash if command not found (possibly recently installed)
zstyle ':completion:*' rehash true

# menu if nb items > 2
zstyle ':completion:*' menu select=2

# dump compdump to /tmp
zstyle ':completion:*' compdump /tmp/.zcompdump

# bind key for backward and forward search for a specific command
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
# bindkey "^[[A" history-search-backward
# bindkey "^[[B" history-search-forward

setopt autocd beep extendedglob nomatch notify
bindkey -v

# set emacs binding
set -o emacs
