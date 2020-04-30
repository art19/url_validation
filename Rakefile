require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
require_relative 'lib/url_validation/version'
require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "url_validation"
  gem.summary = %Q{Simple URL validation in Rails 3}
  gem.description = %Q{A simple, localizable EachValidator for URL fields in ActiveRecord 3.0.}
  gem.email = "git@timothymorgan.info"
  gem.homepage = "http://github.com/riscfuture/url_validation"
  gem.authors = [ "Tim Morgan" ]
  gem.required_ruby_version = '>= 1.8.7'
  gem.version = UrlValidator::VERSION
end
Jeweler::RubygemsDotOrgTasks.new

require 'yard'
YARD::Rake::YardocTask.new('doc') do |doc|
  doc.options << "-m" << "textile"
  doc.options << "--protected" << "--no-private"
  doc.options << "-r" << "README.textile"
  doc.options << "-o" << "doc"
  doc.options << "--title" << "url_validation Documentation".inspect
  doc.files = [ 'lib/*_validator.rb', 'README.textile' ]
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

task :default => :spec
