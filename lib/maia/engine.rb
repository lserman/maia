module Maia
  class Engine < ::Rails::Engine
    isolate_namespace Maia

    require 'mercurius'
    require 'responders'
  end
end
