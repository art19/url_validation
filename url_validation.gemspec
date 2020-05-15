# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'url_validation/version'

Gem::Specification.new do |s|
  s.name                      = 'art19-url_validation'
  s.version                   = UrlValidation::VERSION
  s.metadata                  = { 'github_repo' => 'ssh://github.com/art19/url_validation' }
  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.require_paths             = ['lib']
  s.authors                   = ['Tim Morgan']
  s.date                      = '2020-04-30'
  s.description               = 'A simple, localizable EachValidator for URL fields in ActiveRecord 3.0.'
  s.email                     = 'git@timothymorgan.info'

  s.extra_rdoc_files = %w[LICENSE README.textile]

  s.files = %w[
    .document
    .rspec
    .ruby-gemset
    .ruby-version
    .travis.yml
    Gemfile
    Gemfile.lock
    LICENSE
    README.textile
    Rakefile
    VERSION
    lib/url_validation.rb
    lib/url_validation/version.rb
    spec/spec_helper.rb
    spec/url_validator_spec.rb
    url_validation.gemspec
  ]
  s.homepage = 'http://github.com/riscfuture/url_validation'
  s.required_ruby_version = Gem::Requirement.new('>= 2.6.2')
  s.rubygems_version = '3.1.2'
  s.summary = 'Simple URL validation in Rails 3'

  s.specification_version = 4 if s.respond_to? :specification_version

  s.add_dependency 'activerecord',  '>= 5.1.7'
  s.add_dependency 'activesupport', '>= 5.1.7'

  s.add_dependency 'addressable',   '~> 2.6.0'
  s.add_dependency 'httpi',         '~> 2.4.4'

  s.add_development_dependency 'rake',          '~> 13.0.1'
  s.add_development_dependency 'RedCloth',      '~> 4.3.2'
  s.add_development_dependency 'rspec',         '~> 3.9.0'
  s.add_development_dependency 'rubocop',       '~> 0.82.0'
  s.add_development_dependency 'rubocop-rspec', '~> 1.39.0'
  s.add_development_dependency 'yard',          '~> 0.9.25'
end
