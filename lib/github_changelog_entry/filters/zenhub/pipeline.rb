module GithubChangelogEntry
  module Filters
    module Zenhub
      class Pipeline < Base

        def keep?(issue_w_zenhub)
          return true if !options["pipeline"]
          issue_w_zenhub[:zenhub_data].dig("pipeline", "name") == options["pipeline"]
        rescue RestClient::Forbidden => e
          puts "Request to zenhub failed: #{e.message}, #{e.response.body}"
          false
        end

      end
    end
  end
end
