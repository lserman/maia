describe DevicesController do
  let!(:user) { User.create email: 'test@testerson.com' }

  describe 'POST create' do
    it 'creates a new device for a user' do
      post :create, device: { token: 'token123', platform: 'android' }
      expect(user.reload.devices.size).to eq 1
      expect(user.devices[0].token).to eq 'token123'
      expect(user.devices[0].platform).to eq 'android'
    end

    it 'doesnt create a device without a token' do
      post :create, device: { token: '' }
      expect(user.reload.devices.size).to eq 0
      resp = JSON.parse response.body
      expect(resp['errors']['token']).to be_present
    end

    it 'updates the expiration time whenever POSTing the same device token for a user' do
      post :create, device: { token: 'token123' }
      expiry1 = Maia::Device.last.token_expires_at.to_s(:nsec)
      post :create, device: { token: 'token123' }
      expiry2 = Maia::Device.last.token_expires_at.to_s(:nsec)
      expect(expiry2).to be > expiry1
    end

    it 'sends a dry-run message upon registration to resolve canonical ids' do
      dry_run = double :dry_run
      expect(Maia::DryRun).to receive(:new) { dry_run }
      expect(dry_run).to receive(:send_to).with user
      post :create, device: { token: 'token123' }
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the device from the current users account' do
      user.devices.create token: 'token123'
      expect {
        delete :destroy, id: 'token123'
      }.to change {
        user.reload.devices.count
      }.by(-1)
    end

    it 'returns an error message if no device found' do
      expect {
        delete :destroy, id: 'none'
      }.to raise_error ActiveRecord::RecordNotFound, /Couldn't find Maia::Device/
    end
  end
end
