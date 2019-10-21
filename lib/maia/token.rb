module Maia
  class Token
    include Enumerable

    def initialize(token)
      @token = token
    end

    def each(&block)
      [self].each(&block)
    end

    def to_s
      @token
    end

    def to_h
      { token: @token }
    end
  end
end
