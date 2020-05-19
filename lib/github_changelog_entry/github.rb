require "octokit"
require "paint"
require "byebug"
require "pp"

Octokit.auto_paginate = true

module GithubChangelogEntry
  class Github
    def initialize(github_token, repo)
      @github_token = github_token
      @repo = repo
    end

    def issues(options = {}, ext_filters)
      filters = { state: "closed" }

      if options["since"]
        since = Date.strptime(options["since"], '%Y-%m-%d').to_datetime.iso8601
        filters = filters.merge(since: since)
        puts Paint["Looking for issues after #{since}", :blue]
      end

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
      github_issues_size = issues.size
      puts Paint["-> Retrieved #{github_issues_size} issues from github", :blue]

      if ext_filters && ext_filters.any?
        puts Paint["Applying filters: #{ext_filters.map { |f| f.class.to_s }.join(", ")}", :blue]

        repo_id = client.repository(@repo).id

        issues_w_result = issues.map do |issue|
          {
            issue: issue,
            result_thread: Thread.new do
              Thread.current[:result] = ext_filters.all? { |filter| filter.keep?(repo_id, issue.number) }
            end
          }
        end

        issues_w_result.each do |iwt|
          iwt[:result_thread].join
          iwt[:result] = iwt[:result_thread][:result]
        end

        issues = issues_w_result.select { |iwt| iwt[:result] }.map { |iwt| iwt[:issue] }
        puts Paint["-> Filtered out #{github_issues_size - issues.size} issues using filters", :blue]
      end

      issues
    end

    private

    def milestone(number)
      client.milestone(@repo, number)
    end

    def client
      @client ||= Octokit::Client.new(access_token: @github_token)
    end
  end
end
