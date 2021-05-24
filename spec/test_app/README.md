# README

This is just a test app to test the gem's functionality. This way we don't need
to rely on other apps to test the gem.
The command run to create it was:

```
rails new spec/test_app \
--skip-spring \
--skip-listen \
--skip-bootsnap \
--skip-action-text \
--skip-active-storage \
--skip-action-cable \
--skip-action-mailer \
--skip-action-mailbox \
--skip-test \
--skip-system-test \
--skip-active-job \
--skip-active-record \
--skip-javascript \
--skip-gemfile \
--skip-git
```

This approach was taken broadly following two guides:
- https://dev.to/linqueta/how-to-test-your-gem-in-a-rails-application-2a0a
- https://lokalise.com/blog/how-to-create-a-ruby-gem-testing-suite/#Creating_a_Rails_dummy_application
