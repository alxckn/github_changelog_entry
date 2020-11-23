require "singleton"

module GithubChangelogEntry
  class Logger
    include Singleton

    LEVELS = {
      info:  2,
      warn:  1,
      error: 0,
    }.freeze

    def initialize
      @level = :info
    end

    def set_level(level)
      @level = level
    end

    def error(message, opts = [])
      log(message, opts) if LEVELS[@level] >= LEVELS[:error]
    end

    def warn(message, opts = [])
      log(message, opts) if LEVELS[@level] >= LEVELS[:warn]
    end

    def info(message, opts = [])
      log(message, opts) if LEVELS[@level] >= LEVELS[:info]
    end

    private

    def log(message, opts = [])
      if opts.empty?
        puts message
      else
        puts Paint[message, *opts]
      end
    end
  end
end
