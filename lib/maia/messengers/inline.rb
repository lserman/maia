module Maia
  module Messengers
    class Inline
      def deliver(payload, gateway: Maia.gateway)
        gateway.deliver payload
      rescue Maia::Error::Unregistered => e
        device = Maia::Device.find_by(token: e.token)
        device.destroy
        raise
      end
    end
  end
end
