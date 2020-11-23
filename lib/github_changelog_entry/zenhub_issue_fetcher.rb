require "rest-client"

module GithubChangelogEntry
  class ZenhubIssueFetcher
    API_URL = "https://api.zenhub.io/"

    def initialize(token)
      @token = token
    end

    def fetch_issue(repo_id, issue_number)
      attempts ||= 0
      JSON.parse request(File.join(API_URL, "p1/repositories", repo_id.to_s, "issues", issue_number.to_s)).body
    rescue RestClient::Forbidden => e
      return false if attempts > 4

      puts "Request to zenhub failed: #{e.message}, #{e.response.body} ... Retrying"
      attempts += 1
      sleep 3
      retry
    end

    def request(url)
      RestClient.get(url, params: { access_token: @token })
    end
  end
end
