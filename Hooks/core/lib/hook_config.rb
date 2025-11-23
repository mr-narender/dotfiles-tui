# frozen_string_literal: true

require 'singleton'
require 'yaml'

require_relative 'display'

module Bootstrap
  class HookConfig
    include Singleton

    CONFIG_FILE = File.expand_path('../../../config/hooks.yml', __dir__)

    def initialize
      @data = load_file
      @only = parse_env_list(ENV.fetch('BOOTSTRAP_ONLY', nil))
      @exclude = parse_env_list(ENV.fetch('BOOTSTRAP_EXCLUDE', nil))
    end

    def skipped?(name, stage)
      stage = stage.to_sym

      if @only.any?
        return !@only.fetch(name, {}).fetch(stage, false)
      end

      excluded_by_env?(name, stage) || excluded_by_config?(name, stage)
    end

    def reason_for_skip(name, stage)
      stage = stage.to_sym

      if @only.any? && !@only.fetch(name, {}).fetch(stage, false)
        return 'not included in BOOTSTRAP_ONLY'
      end
      return 'listed in BOOTSTRAP_EXCLUDE' if excluded_by_env?(name, stage)
      return 'disabled in config/hooks.yml' if excluded_by_config?(name, stage)

      nil
    end

    private

    def excluded_by_env?(name, stage)
      entry = @exclude[name] || @exclude[name.to_sym]
      return false if entry.nil?

      entry.fetch(stage, true)
    end

    def excluded_by_config?(name, stage)
      excluded = @data.fetch('excluded_hooks', {})
      value = excluded[name] || excluded[name.to_s] || excluded[name.to_sym]
      case value
      when Hash
        normalize_hash(value).fetch(stage, false)
      when Array
        value.map!(&:to_s)
        value.include?(stage.to_s)
      when true
        true
      else
        false
      end
    end

    def parse_env_list(raw)
      return {} if raw.nil? || raw.strip.empty?

      raw.split(',').each_with_object(Hash.new { |h, k| h[k] = {} }) do |entry, acc|
        hook, stage = entry.strip.split(':', 2)
        next if hook.nil? || hook.empty?

        if stage.nil?
          acc[hook][:'pre'] = true
          acc[hook][:'post'] = true
        else
          acc[hook][stage.to_sym] = true
        end
      end
    end

    def normalize_hash(hash)
      hash.transform_keys(&:to_sym)
    end

    def load_file
      return {} unless File.exist?(CONFIG_FILE)

      YAML.safe_load(File.read(CONFIG_FILE)) || {}
    rescue Psych::SyntaxError => e
      Bootstrap::Display.warn("Invalid YAML in #{CONFIG_FILE}: #{e.message}")
      {}
    end
  end
end
