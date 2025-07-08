# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in bitcoin_ruby_cli.gemspec
# gemspec

gem "rake", "~> 13.0"

gem 'thor'
gem 'bitcoinrb', require: 'bitcoin'

group :test do
    gem 'vcr'
    gem 'webmock'
    gem "rspec", "~> 3.0"
end

group :development, :test do
    gem 'pry'
end