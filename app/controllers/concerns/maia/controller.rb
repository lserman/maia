module Maia
  module Controller
    extend ActiveSupport::Concern

    def create
      if device_exists?
        @device = find_device
        update_device @device
      else
        @device = create_device_token
        send_dry_run_to current_user
      end
      respond_with @device
    end

    def destroy
      @device = find_device params[:id]
      @device.destroy
      respond_with @device
    end

    private
      def device_exists?(token = params[:device][:token])
        current_user.devices.exists? token: token
      end

      def find_device(token = params[:device][:token])
        device = current_user.devices.find_by token: token
        raise ActiveRecord::RecordNotFound.new('Device not found') unless device
        device
      end

      def update_device(device)
        device.attributes = permitted_params
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
        params.require(:device).permit :token, :platform
      end
  end
end
