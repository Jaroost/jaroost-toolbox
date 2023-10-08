require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Psp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Bern"
    # config.eager_load_paths << Rails.root.join("extras")
    # load helper for migrations
    config.autoload_once_paths << Rails.root.join('db', 'lib')


    config.autoload_paths << Rails.root.join('app', 'lib')
    config.eager_load_paths << Rails.root.join('app', 'lib')

    config.action_dispatch.cookies_same_site_protection = :strict


    config.action_mailer.default_url_options = { :host => ENV['APP_PUBLIC_HOST'] }

    Rails.application.routes.default_url_options[:host] = ENV['APP_PUBLIC_HOST']

    I18n.load_path+=Dir[Rails.root.join('config', 'locales', '**', '*.yml')]
    I18n.default_locale= :fr

  end
end
