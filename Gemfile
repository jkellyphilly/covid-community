source 'http://rubygems.org'

gem 'sinatra'
gem 'activerecord', '~> 6.0.6', :require => 'active_record'
gem 'sinatra-activerecord', :require => 'sinatra/activerecord'
gem 'rake'
gem 'require_all'
gem 'thin'
gem 'shotgun'
gem 'pry'
gem 'bcrypt'
gem "tux"

group :development do
  gem 'sqlite3'
end

group :production do
  gem 'pg'
end

group :test do
  gem 'rspec'
  gem 'capybara'
  gem 'rack-test'
  gem 'database_cleaner'
end
