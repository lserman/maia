module Maia
  class Message
    MAX_TOKENS_AT_ONCE = 999

    def send_to(pushable, job_options = {})
      devices = Device.owned_by pushable
      worker = Maia::Messenger.set job_options

      enqueue worker, devices.android, to_h(notify: notify?(:android))
      enqueue worker, devices.ios, to_h(notify: notify?(:ios))
      enqueue worker, devices.unknown, to_h(notify: notify?(:unknown))
    end

    def enqueue(worker, devices, payload)
      devices.pluck(:token).each_slice MAX_TOKENS_AT_ONCE do |tokens|
        worker.perform_later tokens, payload.deep_stringify_keys
      end
    end

    def title
    end

    def body
    end

    def icon
    end

    def sound
      'default'
    end

    def badge
    end

    def color
    end

    def action
    end

    def title_i18n
      []
    end

    def body_i18n
      []
    end

    def data
    end

    def priority
      :normal
    end

    def content_available?
      false
    end

    def dry_run?
      false
    end

    def notify?(_platform = :unknown)
      true
    end

    def notification
      {
        title: title,
        body: body,
        icon: icon,
        sound: sound,
        badge: badge,
        color: color,
        click_action: action
      }.merge(i18n).compact
    end

    def to_h(notify: true)
      payload = {
        priority: priority.to_s,
        dry_run: dry_run?,
        content_available: content_available?,
        data: data
      }

      payload[:notification] = notification if notify
      payload.compact
    end

    private
      def i18n
        {}.tap do |hash|
          hash[:body_loc_key] = body_i18n.first
          hash[:body_loc_args] = body_i18n_args
          hash[:title_loc_key] = title_i18n_key
          hash[:title_loc_args] = title_i18n_args
        end.compact
      end

      def body_i18n_key
        body_i18n.first
      end

      def body_i18n_args
        args = body_i18n.drop 1
        args if args.any?
      end

      def title_i18n_key
        title_i18n.first
      end

      def title_i18n_args
        args = title_i18n.drop 1
        args if args.any?
      end
  end
end
