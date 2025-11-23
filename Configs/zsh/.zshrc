#!/usr/bin/env ruby


# uncomment this and the last line for zprof info for profiling zsh startup time
# zmodload zsh/zprof
# set -x
# shellcheck disable=SC1091
# Load environment variables from .env
set -a
[ -f ~/.env ] && source ~/.env
set +a

[[ -f "${XDG_DATA_HOME:-${HOME}/.local/share}/zap/zap.zsh" ]] && source "${XDG_DATA_HOME:-${HOME}/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
# plug "zap-zsh/zap-prompt"
plug "zsh-users/zsh-syntax-highlighting"

# all of our zsh files
typeset -U zsh_completion
zsh_completion=("${HOME}"/*/completion/*.zsh)

# load the path files
# shellcheck disable=SC2296
# shellcheck disable=SC1090
for file in ${(M)zsh_completion:#*/path.zsh}; do
  [[ -f "${file}" ]] && source "${file}"
done

# load everything but the path and completion files
# shellcheck disable=SC2299
# shellcheck disable=SC1090
for file in ${${zsh_completion:#*/path.zsh}:#*/completion.zsh}; do
  [[ -f "${file}" ]] && source "${file}"
done

# load every completion after autocomplete loads
# shellcheck disable=SC2296
# shellcheck disable=SC1090
for file in ${(M)zsh_completion:#*/completion.zsh}; do
  [[ -f "${file}" ]] && source "${file}"
done

unset zsh_completion

# use .localrc for SUPER SECRET CRAP that you don't
# want in your public, versioned repo.
# shellcheck disable=SC1090
[ -f ~/.localrc ] && source ~/.localrc

# set completion options for uv
eval "$(uv generate-shell-completion zsh)" && source ~/.venv/bin/activate

# zprof
