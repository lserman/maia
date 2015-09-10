module Maia
  module Controller
    extend ActiveSupport::Concern

    def create
      if @device = existing_device
        update_token_expiration @device
      else
        @device = create_device_token
      end
      respond_with @device
    end

    private
      def existing_device
        current_user.devices.find_by token: params[:device][:token]
      end

      def update_token_expiration(device)
        device.reset_token_expiry
        device.save
      end

      def create_device_token
        current_user.devices.create permitted_params
      end

      def permitted_params
        params.require(:device).permit :token
      end
  end
end
