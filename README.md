# GOV.UK Personalisation

A gem to hold shared code which other GOV.UK apps use to implement
accounts-related functionality.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'govuk_personalisation'
```

And then execute:

```
$ bundle install
```

## Usage

### Rails concern

Include the concern into a controller:

```ruby
include GovukPersonalisation::AccountConcern
```

And it will add `before_action` methods to:

- fetch the account session identifier from the request headers, making it available as `account_session_header`
- set a `Vary` response header, to ensure responses for different users are cached differently by the CDN

The following functions are available:

- `logged_in?` - check if there is an account session header
- `set_account_session_header` - replace the current session value, and set the response header the CDN uses to update the user's cookie
- `logout!` - clear the session value, and set the response header the CDN uses to remove the user's cookie

When run in development mode (`RAILS_ENV=development`), a cookie on
`dev.gov.uk` is used instead of custom headers.

### Test helpers

There are test helpers for both request and feature specs to log the
user in.  Include the relevant helper:

```ruby
include GovukPersonalisation::TestHelpers::Requests
```

*or*

```ruby
include GovukPersonalisation::TestHelpers::Features
```

And then log the user in:

```ruby
before do
  mock_logged_in_session
end
```

If you need a specific session identifier, for example to match
against it in WebMock stubs or with the [gds-api-adapters][] test
helpers, you can pass it as an argument:

```ruby
before do
  mock_logged_in_session("your-session-identifier-goes-here")
end
```

[gds-api-adapters]: https://github.com/alphagov/gds-api-adapters

## License

The gem is available as open source under the terms of the [MIT License](LICENCE).
