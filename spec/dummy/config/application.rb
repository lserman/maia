require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'

Bundler.require(*Rails.groups)
require 'maia'

module Dummy
  class Application < Rails::Application
    case Rails::VERSION::MAJOR
    when 5, 6
      config.assets.enabled = false
      config.active_record&.sqlite3&.represent_boolean_as_integer = true
    when 7
      config.active_record.legacy_connection_handling = false
    end

    config.active_job.queue_adapter = :inline
  end
end
