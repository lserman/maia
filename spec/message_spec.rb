describe 'Messaging' do
  let(:user) { users(:logan) }

  context 'All messages successful' do
    it 'sends the message via GCM' do
      stub_request(:post, %r[gcm/send]).to_return body: '{}', status: 200
      TestMessage.new.send_to user

      expect(WebMock).to have_requested(:post, 'https://android.googleapis.com/gcm/send').with body: {
        data: {
          data: 123
        },
        notification: {
          title: 'This is an alert',
          body: 'This is an alert',
          sound: 'default'
        },
        registration_ids: ['logan123']
      }.to_json
    end

    it 'doesnt send a sound if set to explicitly nil' do
      stub_request(:post, %r[gcm/send]).to_return body: '{}', status: 200
      TestMessage.new(sound: nil).send_to user

      expect(WebMock).to have_requested(:post, 'https://android.googleapis.com/gcm/send').with body: {
        data: {
          data: 123
        },
        notification: {
          title: 'This is an alert',
          body: 'This is an alert',
        },
        registration_ids: ['logan123']
      }.to_json
    end

    it 'sends content_available true if content_available? returns truthy' do
      stub_request(:post, %r[gcm/send]).to_return body: '{}', status: 200
      TestMessage.new(content_available: true).send_to user

      expect(WebMock).to have_requested(:post, 'https://android.googleapis.com/gcm/send').with body: {
        data: {
          data: 123
        },
        notification: {
          title: 'This is an alert',
          body: 'This is an alert',
          sound: 'default'
        },
        content_available: true,
        registration_ids: ['logan123']
      }.to_json
    end

    it 'sends badge if set to non-nil' do
      stub_request(:post, %r[gcm/send]).to_return body: '{}', status: 200
      TestMessage.new(badge: 2).send_to user

      expect(WebMock).to have_requested(:post, 'https://android.googleapis.com/gcm/send').with body: {
        data: {
          data: 123
        },
        notification: {
          title: 'This is an alert',
          body: 'This is an alert',
          sound: 'default',
          badge: 2
        },
        registration_ids: ['logan123']
      }.to_json
    end

    it 'sends the message via GCM and ActiveRecord::Relation' do
      stub_request(:post, %r[gcm/send]).to_return body: '{}', status: 200
      TestMessage.new.send_to User.all

      expect(WebMock).to have_requested(:post, 'https://android.googleapis.com/gcm/send').with body: {
        data: {
          data: 123
        },
        notification: {
          title: 'This is an alert',
          body: 'This is an alert',
          sound: 'default',
        },
        registration_ids: ['logan123', 'john123']
      }.to_json
    end
  end

  context 'Device invalid' do
    before do
      expect_any_instance_of(Maia::Messenger).to receive(:connection) { GCM::UnregisteredDeviceTokenConnection.new('logan123') }
    end

    it 'destroys the device from the database' do
      TestMessage.new.send_to User.all
      expect(maia_devices(:john).reload).to be_persisted
      expect { maia_devices(:logan).reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context 'Device has canonical ID' do
    before do
      allow_any_instance_of(Maia::Messenger).to receive(:connection) { GCM::CanonicalIdConnection.new('logan123' => 'canonical123') }
    end

    it 'updates the device token to use a canonical ID if provided' do
      TestMessage.new.send_to User.all
      expect(maia_devices(:logan).reload.token).to eq 'canonical123'
    end

    it 'destroys the device if the user has another device registered with the same canonical ID' do
      users(:logan).devices.first.update token: 'canonical123'
      users(:logan).devices.create token: 'logan123'
      TestMessage.new.send_to users(:logan)
      expect(users(:logan).devices.count).to eq 1
      expect(users(:logan).devices.first.token).to eq 'canonical123'
    end
  end

  context 'GCM key is missing or invalid' do
    it 'raises an exception' do
      stub_request(:post, %r[gcm/send]).to_return body: '{}', status: 401
      expect {
        TestMessage.new.send_to user
      }.to raise_error(Maia::Error) do |e|
        expect(e.message).to eq 'Authentication error with GCM. Check the server whitelist and the validity of your project key.'
      end
    end
  end

  context 'GCM server times out' do
    it 'raises an exception' do
      stub_request(:post, %r[gcm/send]).to_return body: '{}', status: 500
      expect {
        TestMessage.new.send_to user
      }.to raise_error(Maia::Error) do |e|
        expect(e.message).to eq 'GCM Internal server error.'
      end
    end
  end
end
