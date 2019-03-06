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
    option :origin_tag, aliases: "-o", required: false
    option :milestone_number, aliases: "-m", required: false
    def generate
      puts Paint["Generating a new changelog entry", :blue, :bold]

      github_handler = GithubChangelogEntry::Github.new(options[:token], options[:repo])
      GithubChangelogEntry::Generator.new.generate(
        github_handler.closed_issues_after_tag(options[:origin_tag], options[:milestone_number])
      )
    end
  end
end
