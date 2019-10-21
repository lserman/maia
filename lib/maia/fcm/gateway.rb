module Maia
  module FCM
    class Gateway
      def initialize(auth = Maia::FCM::Credentials.new)
        @auth = auth
      end

      def deliver(payload)
        response = Maia::FCM::Response.new connection.write(payload)

        if response.fail?
          error = response.error
          error.payload = payload
          raise error
        end

        response
      end

      def serialize(message, target)
        Maia::FCM::Serializer.new(message, target).to_json
      end

      private
        def connection
          Maia::FCM::Connection.new(@auth.project, @auth.token)
        end
    end
  end
end
