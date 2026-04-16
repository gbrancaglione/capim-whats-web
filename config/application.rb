require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Root namespace for custom app/adapters/ directory.
module Adapters
end

module CapimWhatsWeb
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Use `Adapters` as the Zeitwerk root namespace for app/adapters/, so
    # `app/adapters/whatsapp/cloud_api.rb` defines `Adapters::Whatsapp::CloudApi`.
    initializer :configure_adapters_namespace, after: :set_autoload_paths do |app|
      adapters_dir = Rails.root.join("app/adapters").to_s
      app.config.autoload_paths.delete(adapters_dir)
      app.config.eager_load_paths.delete(adapters_dir)
      Rails.autoloaders.main.push_dir(adapters_dir, namespace: Adapters)
    end

    config.time_zone = "Brasilia"
  end
end
