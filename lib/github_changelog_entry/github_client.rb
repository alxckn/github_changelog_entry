module GithubChangelogEntry
  class GithubClient
    include Singleton

    def set_token(token)
      @token = token
    end

    def client
      @client ||= Octokit::Client.new(access_token: @token)
    end
  end
end
