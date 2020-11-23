require "rest-client"

module GithubChangelogEntry
  module Filters
    module Zenhub
      class Base

        attr_reader :options
        def initialize(zenhub_opts)
          @options = zenhub_opts
        end

      end
    end
  end
end
