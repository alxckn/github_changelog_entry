require "github_changelog_entry/github"

module GithubChangelogEntry
  module Output
    class Changelog
      def generate(issues_w_zenhub)
        issues = issues_w_zenhub.map { |iwz| iwz[:issue] }

        print_version

        print_section("Enhancements")
        print_section("Bugs")
        print_section("Chores")
        print_section("Hotfix")

        issues.each do |issue|
          puts "  - [\\##{issue[:number]}](#{issue[:html_url]}): #{issue[:title]}"
        end
      end

      private

      def print_version
        sep
        new_line
        puts "## <version_number>"
        new_line
      end

      def print_section(section_name)
        puts "### #{section_name}"
        new_line
      end

      def new_line
        puts ""
      end

      def sep
        puts "--"
      end
    end
  end
end
