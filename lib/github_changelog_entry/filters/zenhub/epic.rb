module GithubChangelogEntry
  module Filters
    module Zenhub
      class Epic < Base

        def keep?(repo_id, issue_number)
          return true if !options["epic"]

          epic(repo_id)["issues"].any? { |issue| repo_id == issue["repo_id"] && issue_number == issue["issue_number"] }
        end

        private

        def epic(repo_id)
          @epic ||= begin
            url = File.join(Base::API_URL, "p1/repositories", repo_id.to_s, "epics", options["epic"])
            JSON.parse request(url).body
          end
        end

      end
    end
  end
end
