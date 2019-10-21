module Maia
  module FCM
    class Serializer
      def initialize(message, target)
        @message = message
        @target  = target
      end

      def to_h
        {
          message: {
            data: @message.data.to_h,
            notification: notification.to_h,
            android: android.to_h,
            apns: apns.to_h
          }.merge(@target.to_h)
        }
      end

      def to_json
        to_h.to_json
      end

      private
        def notification
          Maia::FCM::Notification.new @message
        end

        def android
          Maia::FCM::Platform::Android.new @message
        end

        def apns
          Maia::FCM::Platform::APNS.new @message
        end
    end
  end
end
