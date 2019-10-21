require 'rails/all'

require 'maia/engine'
require 'maia/message'
require 'maia/poke'
require 'maia/token'
require 'maia/topic'
require 'maia/devices'

require 'maia/messengers/array'
require 'maia/messengers/inline'
require 'maia/messengers/activejob'

require 'maia/error/generic'
require 'maia/error/unregistered'
require 'maia/error/no_credentials'

require 'maia/fcm/connection'
require 'maia/fcm/credentials'
require 'maia/fcm/gateway'
require 'maia/fcm/notification'
require 'maia/fcm/response'
require 'maia/fcm/serializer'
require 'maia/fcm/platform/android'
require 'maia/fcm/platform/apns'

module Maia
  class << self
    attr_accessor :gateway, :messenger
  end
end

Maia.gateway   = Maia::FCM::Gateway.new
Maia.messenger = Maia::Messengers::ActiveJob.new
