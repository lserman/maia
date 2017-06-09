module Maia
  class Engine < ::Rails::Engine
    isolate_namespace Maia

    require 'responders'
  end
end
