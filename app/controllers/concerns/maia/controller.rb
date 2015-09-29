module Maia
  module Controller
    extend ActiveSupport::Concern

    def create
      if device_exists?
        @device = find_device
        update_token_expiration @device
      else
        @device = create_device_token
        send_dry_run_to current_user
      end
      respond_with @device
    end

    private
      def device_exists?
        current_user.devices.exists? token: params[:device][:token]
      end

      def find_device
        current_user.devices.find_by token: params[:device][:token]
      end

      def update_token_expiration(device)
        device.reset_token_expiry
        device.save
      end

      def create_device_token
        current_user.devices.create permitted_params
      end

      def send_dry_run_to(user)
        Maia::DryRun.new.send_to user
      end

      def permitted_params
        params.require(:device).permit :token
      end
  end
end
