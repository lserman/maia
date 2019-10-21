module Maia
  module Messengers
    class ActiveJob
      def initialize(options = {})
        @options = options
      end

      def deliver(payload)
        MessengerJob.set(@options).perform_later payload
      end

      class MessengerJob < ::ActiveJob::Base
        def perform(payload)
          Maia::Messengers::Inline.new.deliver payload
        end
      end
    end
  end
end
