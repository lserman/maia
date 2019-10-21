module Maia
  module FCM
    class Notification
      def initialize(message)
        @message = message
      end

      def title
        @message.title
      end

      def body
        @message.body
      end

      def image
        @message.image
      end

      def to_h
        {
          title: title,
          body:  body,
          image: image
        }.compact
      end
    end
  end
end
