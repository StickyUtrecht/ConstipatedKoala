ConstipatedKoala::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.action_controller.action_on_unpermitted_parameters = :raise

  # Compress JavaScripts and CSS
  config.assets.compress = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Send e-mails in test mode
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { :host => 'koala.rails.dev', :port => 3000 }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  config.assets.compile = true

  config.serve_static_assets = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Custom configuration
  config.mailgun = ENV['MAILGUN_TOKEN']
  config.checkout = ENV['CHECKOUT_TOKEN']

  # store in public folder for testing purposes
  config.paperclip_defaults = {
    :storage => :filesystem,
    :path => ':rails_root/public/images/:class/:id/:style.:extension',
    :url => '/images/:class/:id/:style.:extension'
  }
end
