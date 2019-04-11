require "thor"
require "paint"
require "json"
require "github_changelog_entry/github"
require "github_changelog_entry/zenhub"
require "github_changelog_entry/generator"
require "byebug"

module GithubChangelogEntry
  class CLI < Thor
    class_option :repo,  desc: "Repository",   aliases: "-r", required: false
    class_option :token, desc: "Github token", aliases: "-t", required: false
    class_option :zenhub_token, desc: "Zenhub token", aliases: "-z", required: false

    desc "generate", "Generates a new changelog raw entry"
    option :default_to_latest_tag,
           aliases: "-l",
           required: false,
           default: false,
           type: :boolean,
           desc: %q{If false, will not try to limit the query to the issues created after a given tag}
    option :origin_tag, aliases: "-o", required: false, desc: %q{Choose a given tag as an origin}
    option :milestone_number, aliases: "-m", required: false, desc: %q{Select issues linked to this milestone (the number needs to be in the milestone title separated by spaces)}
    option :issue_state, aliases: "-s", required: false, default: "all", enum: ["open", "closed", "all"], desc: %q{Override the state parameter}
    option :pipeline, aliases: "-p", required: false, desc: %q{Define a zenhub pipeline parameter to filter with}
    def generate
      puts Paint["Generating a new changelog entry", :blue, :bold]

      tokens_from_file = begin
        JSON.parse File.open(File.join(File.expand_path("~"), ".config/gce/.creds")).read
      rescue
        {}
      end

      tokens = {
        github: options[:token] || tokens_from_file["github"],
        zenhub: options[:zenhub_token] || tokens_from_file["zenhub"],
      }

      github_handler = GithubChangelogEntry::Github.new(tokens[:github], options[:repo])
      zenhub_handler = nil
      if tokens[:zenhub]
        zenhub_handler = GithubChangelogEntry::Zenhub.new(tokens[:zenhub])
      end

      issues_options = options.select do |key, value|
        [
          "origin_tag",
          "milestone_number",
          "default_to_latest_tag",
          "issue_state",
          "pipeline"
        ].include?(key)
      end
      GithubChangelogEntry::Generator.new.generate(
        github_handler.issues(issues_options, zenhub_handler)
      )
    end
  end
end
