module Maia
  module FCM
    module Platform
      class Android
        def initialize(message)
          @message = message
        end

        def color
          @message.color
        end

        def sound
          @message.sound
        end

        def priority
          if @message.priority == :high
            :high
          else
            :normal
          end
        end

        def to_h
          {
            priority: priority.to_s,
            notification: {
              color: color,
              sound: sound,
            }.compact
          }
        end
      end
    end
  end
end
