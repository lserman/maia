module Maia
  module Error
    class Unregistered < Generic
      def token
        json = JSON.parse(payload)
        json['token']
      rescue JSON::ParserError
        nil
      end
    end
  end
end
