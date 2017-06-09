require 'rails'
require 'active_support/core_ext/enumerable'

require 'maia/engine'
require 'maia/message'
require 'maia/messenger'
require 'maia/poke'
require 'maia/dry_run'
require 'maia/error'

require 'maia/fcm'
require 'maia/fcm/connection'
require 'maia/fcm/notification'
require 'maia/fcm/response_collection'
require 'maia/fcm/response'
require 'maia/fcm/result_collection'
require 'maia/fcm/result'
require 'maia/fcm/service'

module Maia
  BATCH_SIZE = 999
end
