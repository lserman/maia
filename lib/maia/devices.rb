module Maia
  class Devices
    include Enumerable

    def initialize(models)
      @models = models
    end

    def each(&block)
      tokens.each(&block)
    end

    def tokens
      return [] if @models.empty?

      Maia::Device.owned_by(@models).tokens.map do |token|
        Maia::Token.new token
      end
    end
  end
end
