#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

gem_home="${script_dir}/.gem"
mkdir -p "${gem_home}"
export GEM_HOME="${gem_home}"
export GEM_PATH="${gem_home}"
export BUNDLE_GEMFILE="${script_dir}/Gemfile"

if [[ -n "${RUBY_BIN:-}" && -x "${RUBY_BIN}" ]]; then
  ruby_bin="${RUBY_BIN}"
elif [[ -x /opt/homebrew/bin/ruby ]]; then
  ruby_bin="/opt/homebrew/bin/ruby"
else
  ruby_bin="$(command -v ruby)"
fi

ruby_dir="$(dirname "${ruby_bin}")"
export PATH="${GEM_HOME}/bin:${ruby_dir}:${PATH}"
gem_bin="${ruby_dir}/gem"

if ! "${gem_bin}" list -i bundler -v 2.4.22 > /dev/null 2>&1; then
  "${gem_bin}" install bundler -v 2.4.22 --no-document
fi

# Suppress RubyGems warnings when using system Ruby
if [[ "${ruby_bin}" == "/usr/bin/ruby" ]]; then
  bundle _2.4.22_ check --gemfile "${script_dir}/Gemfile" 2>&1 | grep -v "RubyGems version" | grep -v "required_ruby_version" | grep -v "gem update --system" || true
  bundle _2.4.22_ install --gemfile "${script_dir}/Gemfile" 2>&1 | grep -v "RubyGems version" | grep -v "required_ruby_version" | grep -v "gem update --system"
else
  bundle _2.4.22_ check --gemfile "${script_dir}/Gemfile" \
    || bundle _2.4.22_ install --gemfile "${script_dir}/Gemfile"
fi

exec ruby "${script_dir}/bootstrap.rb" "$@"
