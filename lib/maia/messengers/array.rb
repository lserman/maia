module Maia
  module Messengers
    class Array
      include Enumerable

      attr_reader :messages

      def initialize
        @messages = []
      end

      def deliver(payload)
        @messages << payload
      end

      def each(&block)
        @messages.map { |msg| JSON.parse(msg) }.each(&block)
      end
    end
  end
end
