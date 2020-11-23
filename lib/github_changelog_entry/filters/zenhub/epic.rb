module GithubChangelogEntry
  module Filters
    module Zenhub
      class Epic < Base

        def keep?(issue_w_zenhub)
          return true if !options["epic"]

          epic(repo_id)["issues"].any? do |issue|
            repo_id == issue_w_zenhub[:issue]["repo_id"] &&
            issue_number == issue_w_zenhub[:issue]["issue_number"]
          end
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
