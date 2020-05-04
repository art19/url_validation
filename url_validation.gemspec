# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'url_validation/version'

Gem::Specification.new do |s|
  s.name = "url_validation".freeze
  s.version = UrlValidation::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tim Morgan".freeze]
  s.date = "2020-04-30"
  s.description = "A simple, localizable EachValidator for URL fields in ActiveRecord 3.0.".freeze
  s.email = "git@timothymorgan.info".freeze
  s.extra_rdoc_files = [
    "LICENSE",
    "README.textile"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".ruby-gemset",
    ".ruby-version",
    ".travis.yml",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "README.textile",
    "Rakefile",
    "VERSION",
    "lib/url_validation.rb",
    "lib/url_validation/version.rb",
    "spec/spec_helper.rb",
    "spec/url_validator_spec.rb",
    "url_validation.gemspec"
  ]
  s.homepage = "http://github.com/riscfuture/url_validation".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7".freeze)
  s.rubygems_version = "3.1.2".freeze
  s.summary = "Simple URL validation in Rails 3".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  s.add_dependency 'addressable',   '~> 2.4.0'
  s.add_dependency 'activesupport', '~> 6.0.2.2'
  s.add_dependency 'activerecord',  '~> 6.0.2.2'
  s.add_dependency 'httpi',         '~> 2.4.4'
  s.add_dependency 'jeweler',       '~> 2.3.9'

  s.add_development_dependency 'yard',          '~> 0.9.25'
  s.add_development_dependency 'RedCloth',      '~> 4.3.2'
  s.add_development_dependency 'rspec',         '~> 3.9.0'
  s.add_development_dependency 'rubocop',       '~> 0.82.0'
  s.add_development_dependency 'rubocop-rspec', '~> 1.39.0'
end
