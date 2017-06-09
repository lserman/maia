module Maia
  module FCM
    class ResponseCollection
      include Enumerable

      def initialize(notification, responses = [])
        @notification = notification
        @responses = responses
      end

      def results
        collection = ResultCollection.new
        @responses.each do |response|
          response.results.each do |result|
            collection << result
          end
        end
        collection
      end

      def [](index)
        @responses[index]
      end

      def <<(response)
        @responses.concat Array(response).flatten
      end

      def each(&block)
        @responses.each(&block)
      end
    end
  end
end
