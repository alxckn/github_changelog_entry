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

This will use all of the issues from the repo.

To find all of the issues in current milestone and zenhub pipeline `Done`, you can use:

`gce g -r <repo_name> -m 19 -p "In Progress"`

### List of options

```
Usage:
  gce generate

Options:
  -l, [--default-to-latest-tag], [--no-default-to-latest-tag]  # If false, will not try to limit the query to the issues created after a given tag
  -o, [--origin-tag=ORIGIN_TAG]                                # Choose a given tag as an origin
  -m, [--milestone-number=MILESTONE_NUMBER]                    # Select issues linked to this milestone (the number needs to be in the milestone title separated by spaces)
  -s, [--issue-state=ISSUE_STATE]                              # Override the state parameter
                                                               # Default: all
                                                               # Possible values: open, closed, all
  -p, [--pipeline=PIPELINE]                                    # Define a zenhub pipeline parameter to filter with
  -r, [--repo=REPO]                                            # Repository
  -t, [--token=TOKEN]                                          # Github token
  -z, [--zenhub-token=ZENHUB_TOKEN]                            # Zenhub token
```

### Save credentials

You can save your credentials in `~/.config/gce/.creds` as json:

```
{
  "github": "<github_token>",
  "zenhub": "<zenhub_token>"
}

```

They will be used unless overriden by a command line argument.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alxckn/github_changelog_entry.
