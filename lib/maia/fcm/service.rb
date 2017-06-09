module Maia
  module FCM
    class Service
      def initialize
        @connection ||= FCM::Connection.new key
      end

      def key
        ENV.fetch 'FCM_KEY', Maia::FCM.key
      end

      def deliver(notification, *tokens, topic: nil)
        responses = ResponseCollection.new notification
        responses << deliver_all(notification, tokens)
        responses << deliver_all(notification, topic) if topic
        responses
      end

      private
        def deliver_all(notification, recipients)
          batch(recipients).map do |batch|
            if batch.many?
              multicast notification, batch
            elsif batch.one?
              unicast notification, batch.first
            end
          end
        end

        def unicast(notification, recipient)
          deliver! notification, recipient, to: recipient
        end

        def multicast(notification, recipients)
          deliver! notification, recipients, registration_ids: recipients
        end

        def deliver!(notification, recipients, params = {})
          payload = notification.to_h.merge params
          Response.new @connection.write(payload), Array(recipients)
        end

        def batch(recipients, batch_size: Maia::BATCH_SIZE)
          Array(recipients).flatten.compact.each_slice batch_size
        end
    end
  end
end
