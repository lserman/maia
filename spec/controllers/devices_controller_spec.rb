describe DevicesController do
  let!(:user) { User.create email: 'test@testerson.com' }

  it 'creates a new device for a user' do
    post :create, device: { token: 'token123' }
    expect(user.reload.devices.size).to eq 1
    expect(user.devices[0].token).to eq 'token123'
  end

  it 'doesnt create a device without a token' do
    post :create, device: { token: '' }
    expect(user.reload.devices.size).to eq 0
    expect(assigns(:device).errors[:token]).to be_present
  end

  it 'updates the expiration time whenever POSTing the same device token for a user' do
    post :create, device: { token: 'token123' }
    expiry1 = Maia::Device.last.token_expires_at.to_s(:nsec)
    post :create, device: { token: 'token123' }
    expiry2 = Maia::Device.last.token_expires_at.to_s(:nsec)
    expect(expiry2).to be > expiry1
  end

end
