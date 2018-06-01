
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{ repo_name }/#{ repo_name }" unless repo_name.include?("/")
  "https://github.com/#{ repo_name }.git"
end

gem 'mysql2'
gem 'rails'

# use of Haml and rabl
gem 'haml'
gem 'rabl'

# assets and stuff
gem 'coffee-rails'
gem 'sass-rails'

# authentication gems
gem 'devise', :github => 'plataformatec/devise'
gem 'doorkeeper'

gem 'impressionist'

# rests calls for mailgun
gem 'rest-client'

# search engine
gem 'fuzzily', :github => 'svsticky/fuzzily'
gem 'responders'

# settings cached in rails environment
gem 'rails-settings-cached'

# Paperclip easy file upload to S3
gem 'cocaine', '0.3.2'
gem 'paperclip'

group :production, :staging do
  gem 'sentry-raven'
  gem 'uglifier'
  gem 'unicorn'
end

group :development, :test, :staging do
  gem 'faker'
end

group :development do
  gem 'listen'
  gem 'puma'

  gem 'byebug', platform: :mri
  gem 'web-console'
end

group :development, :test do
  gem 'rubocop'
  gem 'spring'
end

# Added at 2018-01-12 12:01:35 +0100 by cdfa:
gem "i15r", "~> 0.5.5"
