module Maia
  class Message
    MAX_TOKENS_AT_ONCE = 999

    def send_to(pushable)
      devices =
        case pushable
        when ActiveRecord::Relation
          Device.owned_by pushable
        when ActiveRecord::Base
          pushable.devices
        else
          raise ArgumentError.new
        end

      enqueue devices, to_h
    end

    def enqueue(devices, payload)
      devices.pluck(:token).each_slice(MAX_TOKENS_AT_ONCE) do |tokens|
        Maia::Messenger.perform_later tokens, payload.deep_stringify_keys
      end
    end

    def alert
      ''
    end

    def badge
      nil
    end

    def sound
      'default'
    end

    def other
      {}
    end

    def content_available?
      false
    end

    def to_h
      {
        data: other,
        content_available: content_available?,
        notification: {
          title: alert,
          body: alert,
          sound: sound,
          badge: badge
        }.compact
      }
    end
  end
end
