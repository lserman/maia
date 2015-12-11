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
    end

    def sound
      'default'
    end

    def other
      {}
    end

    def priority
    end

    def content_available?
      false
    end

    def dry_run?
      false
    end

    def to_h
      hash = {
        data: other,
        notification: {
          title: alert,
          body: alert,
          sound: sound,
          badge: badge
        }.compact
      }

      hash.merge!(priority: priority.to_s) if priority
      hash.merge!(dry_run: true) if dry_run?
      hash.merge!(content_available: true) if content_available?
      hash
    end
  end
end
