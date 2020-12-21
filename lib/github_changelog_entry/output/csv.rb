require "github_changelog_entry/github"

module GithubChangelogEntry
  module Output
    class Csv
      def generate(repo, issues_w_zenhub)
        headers = %w[
          repo
          number
          title
          url
          assignee
          assigned_at
          closed_at
          deduced_timing
          estimate
        ]
        Logger.instance.info(headers.join(";"))

        client = GithubClient.instance.client

        issues_w_zenhub.each do |iwz|
          issue = iwz[:issue]
          zenhub_data = iwz[:zenhub_data]

          issue_events = client.issue_events(repo, issue.number)
          assigned_event = issue_events.select { |e| e.event == "assigned" }.last

          data = [
            repo,
            issue[:number],
            issue[:title],
            issue[:html_url],
            assigned_event&.assignee&.login,
            assigned_event&.created_at,
            issue.closed_at,
            (((issue.closed_at || Time.now.utc) - (assigned_event&.created_at || Time.now.utc)) / 3600 / 24).round(1),
            zenhub_data["estimate"]["value"],
          ]

          Logger.instance.warn(data.join(";"))
        end
      end

    end
  end
end
