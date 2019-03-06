require "test_helper"

class GithubChangelogEntryTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::GithubChangelogEntry::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
