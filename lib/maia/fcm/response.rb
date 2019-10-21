module Maia
  module FCM
    class Response
      def initialize(response)
        @response = response
      end

      def body
        @response.body
      end

      def status
        @response.code.to_i
      end

      def success?
        (200..399).cover? status
      end

      def fail?
        !success?
      end

      def error
        case json.dig('error', 'status')
        when 'UNREGISTERED'
          Maia::Error::Unregistered.new
        else
          Maia::Error::Generic.new json.dig('error', 'message')
        end
      end

      private
        def json
          JSON.parse body
        rescue JSON::ParserError
          {}
        end
    end
  end
end
