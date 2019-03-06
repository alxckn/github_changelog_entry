# Github Changelog Entry

Simple changelog assistant for a team working with github. Fetches issues from github and outputs them in a format that can be copy pasted into your changelog and edited to fit your needs.

The idea here is NOT to have a fully automatic changelog.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "github_changelog_entry"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install github_changelog_entry

## Usage

### Generating a new changelog entry

`gce generate -t <github_token> -r <repo_name>`

This will use all of the issues created since the last release.

### Choose a given release

`gce generate -t <github_token> -r <repo_name> -o 2.9.1`

This will use all of the issues created since the `2.9.1` release.

### Filter by milestone

`gce generate -t <github_token> -r <repo_name> -o 2.9.1 -m 2`

This will use all of the issues created since the `2.9.1` release linked to a milestone with ` 2 ` in the title.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alxckn/github_changelog_entry.
