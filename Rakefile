# frozen_string_literal: true

require 'bundler'
require 'rake'
require 'rubygems'
require 'yard'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end

YARD::Rake::YardocTask.new('doc') do |doc|
  doc.options << '-m' << 'textile'
  doc.options << '--protected' << '--no-private'
  doc.options << '-r' << 'README.textile'
  doc.options << '-o' << 'doc'
  doc.options << '--title' << 'url_validation Documentation'.inspect
  doc.files = ['lib/*_validator.rb', 'README.textile']
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

desc 'Build the package and publish it to rubygems.pkg.github.com'
task publish: :build do
  require 'url_validation'

  raise 'Set environment variable GEM_PUSH_KEY to the name of a key in ~/.gem/credentials' unless ENV['GEM_PUSH_KEY']

  system("gem push --key #{ENV['GEM_PUSH_KEY']} --host https://rubygems.pkg.github.com/art19 " \
         "pkg/url_validation-#{UrlValidator::VERSION}.gem")
end

task default: :spec
