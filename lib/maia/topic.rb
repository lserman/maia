module Maia
  class Topic
    include Enumerable

    def initialize(topic)
      @topic = topic
    end

    def each(&block)
      [self].each(&block)
    end

    def to_s
      @topic
    end

    def to_h
      { topic: @topic }
    end
  end
end
