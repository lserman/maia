module Maia
  class Message
    def send_to(pushable, job_options = {})
      devices = Device.owned_by pushable
      worker  = Messenger.set job_options

      enqueue worker, devices.android
      enqueue worker, devices.ios
      enqueue worker, devices.unknown
    end

    def enqueue(worker, devices)
      devices.in_batches(of: Maia::BATCH_SIZE) do |devices|
        worker.perform_later devices.pluck(:token), to_h.deep_stringify_keys
      end
    end

    def title
    end

    def body
    end

    def on_click
    end

    def icon
    end

    def sound
      :default
    end

    def badge
    end

    def color
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

    def notification
      {
        title: title,
        body: body,
        icon: icon,
        sound: sound.to_s,
        badge: badge,
        color: color,
        click_action: on_click
      }.compact
    end

    def to_h
      {
        priority: priority.to_s,
        dry_run: dry_run?,
        content_available: content_available?,
        data: data,
        notification: notification
      }.compact
    end
  end
end
