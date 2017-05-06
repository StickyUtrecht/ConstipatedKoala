# encoding: UTF-8
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails'
gem 'mysql2'

# use of Haml and rabl
gem 'haml'
gem 'rabl'

# sprockets for assets
gem 'sprockets'
# gem 'sass-rails'

# authentication gems
gem 'devise', :github => 'plataformatec/devise'
gem 'doorkeeper'

# logging
gem 'impressionist'

# rests calls for mailgun
gem 'rest-client'

# new search engine
gem 'fuzzily'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'responders'

# settings cached in rails environment
gem 'rails-settings-cached'

# Paperclip easy file upload to S3
gem 'paperclip'

# fancy JS alert and confirm
gem 'sweetalert-rails'

# Clipboard: Saved text to clipboard
gem 'clipboard-rails'

group :production do
  gem 'unicorn'
  gem 'aws-sdk', '>= 2.0'
  gem 'uglifier'
end

group :development do
  gem 'puma'

  gem 'web-console'
  gem 'byebug', platform: :mri

  gem 'faker'
  gem 'spring'
end

group :test do
  gem 'spring'
  gem 'faker'
end
