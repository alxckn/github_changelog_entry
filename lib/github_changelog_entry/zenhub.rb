require "rest-client"

module GithubChangelogEntry
  class Zenhub
    API_URL = "https://api.zenhub.io/"

    def initialize(token)
      @token = token
    end

    def issue_pipeline(repo_id, issue_number)
      fetch_issue(repo_id, issue_number).dig("pipeline", "name")
    end

    private

    def fetch_issue(repo_id, issue_number)
      JSON.parse request(File.join(API_URL, "p1/repositories", repo_id.to_s, "issues", issue_number.to_s)).body
    end

    def request(url)
      RestClient.get(url, params: { access_token: @token })
    end

  end
end
