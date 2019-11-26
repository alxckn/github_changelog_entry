require "thor"
require "paint"
require "json"
require "byebug"

require "github_changelog_entry/github"
require "github_changelog_entry/logger"

require "github_changelog_entry/filters/zenhub/base"
require "github_changelog_entry/filters/zenhub/pipeline"
require "github_changelog_entry/filters/zenhub/epic"

module GithubChangelogEntry
  class CLI < Thor
    class_option :repo,  desc: "Repository",   aliases: "-r", required: false
    class_option :token, desc: "Github token", aliases: "-t", required: false
    class_option :zenhub_token, desc: "Zenhub token", aliases: "-z", required: false

    no_commands do
      def set_tokens
        @github_token = options[:token]        || tokens_from_file["github"]
        @zenhub_token = options[:zenhub_token] || tokens_from_file["zenhub"]
      end

      def tokens_from_file
        @tokens_from_file ||= JSON.parse File.open(File.join(File.expand_path("~"), ".config/gce/.creds")).read
      rescue
        {}
      end

      def filters
        to_r = []

        if @zenhub_token
          to_r << GithubChangelogEntry::Filters::Zenhub::Pipeline.new(@zenhub_token, options[:zenhub_opts])
          to_r << GithubChangelogEntry::Filters::Zenhub::Epic.new(@zenhub_token, options[:zenhub_opts])
        end

        to_r
      end
    end

    desc "generate", "Generates a new changelog raw entry"
    option :since, aliases: "-s", desc: %q{Date after which we want to search for issues}
    option :milestone, aliases: "-m", desc: %q{Select issues linked to these milestones (ids)}
    option :issue_state, default: "all", enum: ["open", "closed", "all"], desc: %q{Show only closed or open issues}
    option :zenhub_opts, type: :hash, desc: %q{Defines zenhub options}
    def generate
      puts Paint["Generating a new changelog entry", :blue, :bold]

      set_tokens

      github_handler = GithubChangelogEntry::Github.new(@github_token, options[:repo])

      issues_options = options.select { |key, value| %w[since milestone issue_state].include?(key) }
      issues = github_handler.issues(issues_options, filters)

      GithubChangelogEntry::Logger.new.generate(issues)
    end
  end
end
