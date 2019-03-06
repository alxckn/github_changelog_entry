require "octokit"
require "paint"

module GithubChangelogEntry
  class Github
    def initialize(github_token, repo)
      @github_token = github_token
      @repo = repo
    end

    def closed_issues_after_tag(tag_name = nil, milestone_number = nil)
      return unless tag_commit = commit(tag_name)

      filters = {
        state: "closed",
        since: tag_commit[:commit][:committer][:date]
      }

      if milestone_number
        m = milestone(milestone_number)
        unless m.nil?
          filters.merge!(milestone: m[:number])
          puts Paint["Using milestone #{m[:title]}", :blue]
        end
      end

      client.list_issues(@repo, filters).reject { |issue| issue.key?(:pull_request) }
    end

    private

    def milestone(number)
      client.list_milestones(@repo).find { |m| m[:title].include?(" #{number} ") }
    end

    def commit(tag_name)
      tag = tag_name ? tags[clean_tag_name(tag_name)] : tags[tags.keys.sort.last]

      puts Paint["Using tag version #{clean_tag_ref(tag[:ref])}", :blue]

      client.commit(@repo, tag[:object][:sha])
    end

    def tags
      @tags ||= Hash[
        client.refs(@repo, :tag)
        .map { |ref| [clean_tag_ref(ref[:ref]), ref] }
        .reject { |ref| ref[0].nil? }
      ]
    end

    def clean_tag_ref(ref)
      tag = ref.match(/(\d+\.)?(\d+\.)?(\*|\d+)$/)
      tag[0] if tag
    end

    def clean_tag_name(tag_name)
      tag_name.gsub("v", "")
    end

    def client
      @client ||= Octokit::Client.new(access_token: @github_token)
    end
  end
end