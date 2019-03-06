require "thor"
require "paint"
require "github_changelog_entry/github"
require "github_changelog_entry/generator"
require "byebug"

module GithubChangelogEntry
  class CLI < Thor
    class_option :repo,  desc: "Repository",   aliases: "-r", required: true
    class_option :token, desc: "Github token", aliases: "-t", required: true

    desc "generate", "Generates a new changelog raw entry"
    option :default_to_latest_tag,
           aliases: "-l",
           required: false,
           default: true,
           type: :boolean,
           desc: %q{If false, will not try to limit the query to the issues created after a given tag}
    option :origin_tag, aliases: "-o", required: false, desc: %q{Choose a given tag as an origin}
    option :milestone_number, aliases: "-m", required: false, desc: %q{Select issues linked to this milestone (the number needs to be in the milestone title separated by spaces)}
    option :issue_state, aliases: "-s", required: false, default: "closed", enum: ["open", "closed", "all"], desc: %q{Override the state parameter}
    def generate
      puts Paint["Generating a new changelog entry", :blue, :bold]

      github_handler = GithubChangelogEntry::Github.new(options[:token], options[:repo])

      issues_options = options.select do |key, value|
        [
          "origin_tag",
          "milestone_number",
          "default_to_latest_tag",
          "issue_state"
        ].include?(key)
      end
      GithubChangelogEntry::Generator.new.generate(
        github_handler.closed_issues(issues_options)
      )
    end
  end
end
