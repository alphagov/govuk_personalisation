# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "govuk_personalisation/version"

Gem::Specification.new do |spec|
  spec.name          = "govuk_personalisation"
  spec.version       = GovukPersonalisation::VERSION
  spec.authors       = ["GOV.UK Dev"]
  spec.email         = ["govuk-dev@digital.cabinet-office.gov.uk"]

  spec.summary       = "A gem to hold shared code which other GOV.UK apps will use to implement accounts-related functionality."
  spec.description   = "A gem to hold shared code which other GOV.UK apps will use to implement accounts-related functionality."
  spec.homepage      = "https://github.com/alphagov/govuk_personalisation"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.6")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{\A(?:test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_dependency "plek", ">= 1.9.0"
  spec.add_dependency "rails", ">= 6", "< 8"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "climate_control"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "rubocop-govuk", "4.9.0"
end
