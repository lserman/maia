module Maia
  module FCM
    class Connection
      def initialize(project, token)
        @project = project
        @token   = token
      end

      def write(payload = {})
        request = Net::HTTP::Post.new uri, headers
        request.body = payload
        http.request request
      end

      private
        def uri
          URI("https://fcm.googleapis.com/v1/projects/#{@project}/messages:send")
        end

        def headers
          {
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{@token}"
          }
        end

        def http
          @_http ||= Net::HTTP.new(uri.host, uri.port).tap do |h|
            h.use_ssl = true
          end
        end
    end
  end
end
