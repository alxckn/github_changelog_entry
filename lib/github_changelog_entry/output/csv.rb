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
          estimate
        ]
        puts headers.join(";")

        issues_w_zenhub.each do |iwz|
          issue = iwz[:issue]
          zenhub_data = iwz[:zenhub_data]

          data = [
            repo,
            issue[:number],
            issue[:title],
            issue[:html_url],
            zenhub_data["estimate"]["value"],
          ]

          puts data.join(";")
        end
      end

    end
  end
end
