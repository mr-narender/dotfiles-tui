# frozen_string_literal: true

require 'shellwords'

require_relative '../core/common'

Bootstrap::Hooks.run('lazyvim', stage: :pre) do |hook|
  nvim_dir = hook.home_path('.config', 'nvim')
  nvim_dir_escaped = Shellwords.escape(nvim_dir)

  if File.directory?(nvim_dir)
    if File.directory?(File.join(nvim_dir, '.git'))
      hook.run("git -C #{nvim_dir_escaped} pull --ff-only", allow_failure: true)
    else
      hook.info("Skipping LazyVim clone: #{nvim_dir} already exists")
    end
    next
  end

  hook.run("git clone https://github.com/LazyVim/starter #{nvim_dir_escaped}")
end
