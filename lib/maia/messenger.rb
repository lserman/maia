module Maia
  class Messenger < ActiveJob::Base
    def perform(tokens, payload)
      logger.info "Pushing to #{tokens.size} token(s)..."
      logger.info "Payload: #{payload}"

      notification = FCM::Notification.new payload
      responses    = fcm.deliver notification, tokens

      responses.each do |response|
        raise Maia::Error, response.error if response.error
        handle_errors response.results.failed
        update_devices_to_use_canonical_ids response.results.with_canonical_ids
      end
    end

    private
      def fcm
        @_service ||= FCM::Service.new
      end

      def handle_errors(results)
        results.each do |result|
          device = Maia::Device.find_by token: result.token
          next unless device.present?

          if device_unrecoverable? result.error
            log_error "Destroying device #{device.id}", result, device
            device.destroy
          else
            log_error "Push to device #{device.id} failed", result, device
          end
        end
      end

      def device_unrecoverable?(error)
        error =~ /InvalidRegistration|NotRegistered|MismatchSenderId/
      end

      def log_error(message, result, device)
        logger.info "#{message} (error: #{result.error}, token: #{device.token})"
      end

      def update_devices_to_use_canonical_ids(results)
        results.each do |result|
          device = Maia::Device.find_by token: result.token
          next if device.nil?

          if user_already_has_token_registered?(device.pushable, result.canonical_id)
            device.destroy
          else
            device.update token: result.canonical_id
          end
        end
      end

      def user_already_has_token_registered?(user, token)
        user.devices.exists? token: token
      end
  end
end
