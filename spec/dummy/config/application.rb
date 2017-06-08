require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)
require 'maia'

module Dummy
  class Application < Rails::Application
    config.active_job.queue_adapter = :inline
  end
end
