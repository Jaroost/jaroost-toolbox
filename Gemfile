source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

gem 'vite_rails'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails"

# Use PostgressQl as the database
gem 'pg'


# pour gérer le current user
gem 'devise'
#Pour permettre l'authentification avec des providers Oauth2 (comme keycloak)
gem 'omniauth'
#Pour faire notre stratégie pour keycloak
gem 'omniauth-oauth2'
# Pour lire les token de keycloak
gem 'json-jwt'
# Pour la vérification du csrf lors du processus de connexion oauth2
gem "omniauth-rails_csrf_protection"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

#Pour les authorization
gem 'cancancan'

# Use Redis adapter to run Action Cable in production
# gem "redis"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
# gem "sassc-rails"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]

  #Gem for testing
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem "faker", "~> 3.2"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium"
  gem "webdrivers"
end

gem "bootstrap_form", "~> 5.2"

