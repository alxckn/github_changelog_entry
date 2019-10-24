require "octokit"
require "paint"
require "byebug"
require "pp"

module GithubChangelogEntry
  class Github
    def initialize(github_token, repo)
      @github_token = github_token
      @repo = repo
    end

    def issues(options = {}, ext_filters)
      filters = { state: "closed" }

      tag_commit = if options["since"]
        commit(options["since"])
      end
      filters = filters.merge(since: tag_commit[:commit][:committer][:date]) if tag_commit

      if options["milestone"]
        m = milestone(options["milestone"])
        unless m.nil?
          filters.merge!(milestone: m[:number])
          puts Paint["Using milestone #{m[:title]}", :blue]
        end
      end

      if options["issue_state"]
        filters.merge!(state: options["issue_state"])
      end

      issues = client.list_issues(@repo, filters).reject { |issue| issue.key?(:pull_request) }

      if ext_filters && ext_filters.any?
        repo_id = client.repository(@repo).id
        issues = issues.select do |issue|
          ext_filters.all? { |filter| filter.keep?(repo_id, issue.number) }
        end
      end

      issues
    end

    private

    def milestone(number)
      client.milestone(@repo, number)
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
