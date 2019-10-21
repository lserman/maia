module Maia
  class Message
    def title; end
    def body;  end
    def image; end
    def badge; end
    def color; end
    def background?; end
    def priority; end

    def data
      {}
    end

    def sound
      'default'
    end

    def targeting(target)
      tap { @target = target }
    end

    def to_json
      to_h.to_json
    end

    def send_to(*models, topic: nil, token: nil, messenger: Maia.messenger)
      targets = []
      targets << Maia::Topic.new(topic) if topic
      targets << Maia::Token.new(token) if token

      Maia::Devices.new(models).each do |t|
        targets << t
      end

      targets.map do |target|
        messenger.deliver Maia.gateway.serialize(self, target)
      end
    end
  end
end
