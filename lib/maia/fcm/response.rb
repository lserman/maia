module Maia
  module FCM
    class Response
      attr_reader :http_response, :tokens

      def initialize(http_response, tokens = [])
        @http_response = http_response
        @tokens = tokens
      end

      def status
        http_response.code
      end

      def success?
        (200..399).cover? status
      end

      def fail?
        !success?
      end

      def results
        @_results ||= begin
          results = to_h.fetch 'results', []
          results.map!.with_index do |attributes, i|
            Result.new attributes, tokens[i]
          end
          ResultCollection.new(results)
        end
      end

      def error
        case status
        when 400
          'Invalid JSON was sent to FCM.'
        when 401
          'Authentication error with FCM. Check the server whitelist and the validity of your project key.'
        when 500..599
          'FCM Internal server error.'
        end
      end

      def retry_after
        http_response.headers['Retry-After']
      end

      def to_h
        JSON.parse http_response.body
      rescue JSON::ParserError
        {}
      end
    end
  end
end
