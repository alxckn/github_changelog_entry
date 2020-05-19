module GithubChangelogEntry
  module Filters
    module Zenhub
      class Pipeline < Base

        def keep?(repo_id, issue_number)
          return true if !options["pipeline"]
          fetch_issue(repo_id, issue_number).dig("pipeline", "name") == options["pipeline"]

        rescue RestClient::Forbidden => e
          puts "Request to zenhub failed: #{e.message}, #{e.response.body}"
          false
        end

      end
    end
  end
end
