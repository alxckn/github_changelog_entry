require "octokit"
require "paint"
require "byebug"
require "pp"

Octokit.auto_paginate = true

module GithubChangelogEntry
  class Github
    def initialize(repo)
      @repo = repo
    end

    def issues(options = {}, zenhub_fetcher, ext_filters)
      filters = { state: "closed" }

      if options["since"]
        since = Date.strptime(options["since"], '%Y-%m-%d').to_datetime.iso8601
        filters = filters.merge(since: since)
        Logger.instance.info("Looking for issues after #{since}", [:blue])
      end

      if options["milestone"]
        m = milestone(options["milestone"])
        unless m.nil?
          filters.merge!(milestone: m[:number])
          Logger.instance.info("Using milestone #{m[:title]}", [:blue])
        end
      end

      if options["issue_state"]
        filters.merge!(state: options["issue_state"])
      end

      if options["assignee"]
        filters.merge!(assignee: options["assignee"])
      end

      issues = client.list_issues(@repo, filters).reject { |issue| issue.key?(:pull_request) }
      github_issues_size = issues.size
      Logger.instance.info("-> Retrieved #{github_issues_size} issues from github", [:blue])

      # Here we "augment" issues with zenhub info
      issues_w_zenhub = augment_issues_with_zenhub_data(issues, zenhub_fetcher)

      if ext_filters && ext_filters.any?
        Logger.instance.info("Applying filters: #{ext_filters.map { |f| f.class.to_s }.join(", ")}", [:blue])

        issues_w_zenhub = issues_w_zenhub.select { |iwz| ext_filters.all? { |filter| filter.keep?(iwz) } }
        Logger.instance.info("-> Filtered out #{github_issues_size - issues_w_zenhub.size} issues using filters", [:blue])
      end

      issues_w_zenhub
    end

    private

    def augment_issues_with_zenhub_data(issues, zenhub_fetcher)
      repo_id = client.repository(@repo).id

      issues_w_zenhub = issues.map do |issue|
        {
          issue: issue,
          result_thread: Thread.new do
            Thread.current[:zenhub_data] = zenhub_fetcher.fetch_issue(repo_id, issue.number)
          end
        }
      end

      issues_w_zenhub.each do |iwz|
        iwz[:result_thread].join
        iwz[:zenhub_data] = iwz[:result_thread][:zenhub_data]
      end

      issues_w_zenhub
    end

    def milestone(milestone_title)
      client
        .list_milestones(@repo, { state: "open", direction: "desc" })
        .find { |m| m.title == milestone_title }
    end

    def client
      @client ||= GithubClient.instance.client
    end
  end
end
