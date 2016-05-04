describe Maia::Message do
  let(:user) { users(:logan) }
  let(:message) { Maia::Message.new }

  describe '#send_to' do
    it 'sends the to_h payload via GCM' do
      allow(message).to receive(:to_h) { Hash[test: true] }
      stub_request(:post, %r{gcm/send}).to_return body: '{}', status: 200
      message.send_to user
      expect(WebMock).to have_requested(:post, 'https://android.googleapis.com/gcm/send').with body: { test: true, registration_ids: ['logan123'] }.to_json
    end

    it "doesn't enqueue a worker when the devices for that platform are empty" do
      stub_request(:post, %r{gcm/send}).to_return body: '{}', status: 200
      expect(Maia::Messenger).to receive(:perform_later).once
      message.send_to user
    end

    it 'sends a message later' do
      stub_request(:post, %r{gcm/send}).to_return body: '{}', status: 200
      expect(Maia::Messenger).to receive(:set).with(wait: 30.seconds) { Maia::Messenger }
      message.send_to user, wait: 30.seconds
    end

    it 'sends the message via GCM and ActiveRecord::Relation' do
      stub_request(:post, %r{gcm/send}).to_return body: '{}', status: 200
      message.send_to User.all
      expect(WebMock).to have_requested(:post, 'https://android.googleapis.com/gcm/send').with body: hash_including(registration_ids: %w(logan123 john123))
    end

    it "doesn't notify the user when notify? returns false" do
      stub_request(:post, %r{gcm/send}).to_return body: '{}', status: 200
      allow(message).to receive(:notify?) { |platform| platform != :unknown }
      expect(message).to receive(:to_h).with(notify: false).once.and_call_original
      expect(message).to receive(:to_h).with(notify: true).twice.and_call_original
      message.send_to user
    end
  end

  describe '#to_h' do
    describe :priority do
      it 'sends "normal" by default' do
        expect(message.to_h[:priority]).to eq 'normal'
      end

      it 'can be overridden by #priority' do
        expect(message).to receive(:priority) { :high }
        expect(message.to_h[:priority]).to eq 'high'
      end
    end

    describe :dry_run do
      it 'sends "false" as the default' do
        expect(message.to_h[:dry_run]).to eq false
      end

      it 'sends "true" if dry_run? returns true' do
        expect(message).to receive(:dry_run?) { true }
        expect(message.to_h[:dry_run]).to eq true
      end
    end

    describe :content_available do
      it 'sends "false" as the default' do
        expect(message.to_h[:content_available]).to eq false
      end

      it 'sends "true" if content_available? returns true' do
        expect(message).to receive(:content_available?) { true }
        expect(message.to_h[:content_available]).to eq true
      end
    end

    describe :data do
      it 'does not get sent by default' do
        expect(message.to_h).to_not include :data
      end

      it 'is equal to the hash returned by #data' do
        expect(message).to receive(:data) { Hash[test: true] }
        expect(message.to_h[:data][:test]).to eq true
      end
    end

    describe :notification do
      it 'does not get sent if notify keyword arg is false' do
        expect(message.to_h(notify: false)).to_not include :notification
      end
    end

    describe :title do
      it 'does not get sent by default' do
        expect(message.to_h[:notification]).to_not include :title
      end

      it 'sends the result of #title' do
        expect(message).to receive(:title) { 'Test' }
        expect(message.to_h[:notification][:title]).to eq 'Test'
      end
    end

    describe :body do
      it 'does not get sent by default' do
        expect(message.to_h[:notification]).to_not include :body
      end

      it 'sends the result of #body' do
        expect(message).to receive(:body) { 'Test' }
        expect(message.to_h[:notification][:body]).to eq 'Test'
      end
    end

    describe :icon do
      it 'does not get sent by default' do
        expect(message.to_h[:notification]).to_not include :icon
      end

      it 'sends the result of #icon' do
        expect(message).to receive(:icon) { 'icn_test' }
        expect(message.to_h[:notification][:icon]).to eq 'icn_test'
      end
    end

    describe :sound do
      it 'sends "default" as the default sound' do
        expect(message.to_h[:notification][:sound]).to eq 'default'
      end

      it "doesn't contain a sound if explicitly nil" do
        expect(message).to receive(:sound) { nil }
        expect(message.to_h[:notification]).to_not include :sound
      end
    end

    describe :badge do
      it 'does not send by default' do
        expect(message.to_h[:notification]).to_not include :badge
      end

      it 'sends the number returned by #badge' do
        expect(message).to receive(:badge) { 5 }
        expect(message.to_h[:notification][:badge]).to eq 5
      end
    end

    describe :color do
      it 'does not send by default' do
        expect(message.to_h[:notification]).to_not include :color
      end

      it 'sends the number returned by #color' do
        expect(message).to receive(:color) { '#ffffff' }
        expect(message.to_h[:notification][:color]).to eq '#ffffff'
      end
    end

    describe :click_action do
      it 'does not send by default' do
        expect(message.to_h[:notification]).to_not include :click_action
      end

      it 'sends the number returned by #click_action' do
        expect(message).to receive(:action) { 'TEST_123' }
        expect(message.to_h[:notification][:click_action]).to eq 'TEST_123'
      end
    end

    describe :body_loc_key do
      it 'does not send by default' do
        expect(message.to_h[:notification]).to_not include :body_loc_key
      end

      it 'sends the i18n key from body_i18n' do
        allow(message).to receive(:body_i18n) { %w(key arg1 arg2) }
        expect(message.to_h[:notification][:body_loc_key]).to eq 'key'
      end
    end

    describe :body_loc_args do
      it 'does not send by default' do
        expect(message.to_h[:notification]).to_not include :body_loc_args
      end

      it 'sends the i18n args from body_i18n' do
        allow(message).to receive(:body_i18n) { %w(key arg1 arg2) }
        expect(message.to_h[:notification][:body_loc_args]).to eq %w(arg1 arg2)
      end
    end

    describe :title_loc_key do
      it 'does not send by default' do
        expect(message.to_h[:notification]).to_not include :title_loc_key
      end

      it 'sends the i18n key from title_i18n' do
        allow(message).to receive(:title_i18n) { %w(key arg1 arg2) }
        expect(message.to_h[:notification][:title_loc_key]).to eq 'key'
      end
    end

    describe :title_loc_args do
      it 'does not send by default' do
        expect(message.to_h[:notification]).to_not include :title_loc_args
      end

      it 'sends the i18n args from title_i18n' do
        allow(message).to receive(:title_i18n) { %w(key arg1 arg2) }
        expect(message.to_h[:notification][:title_loc_args]).to eq %w(arg1 arg2)
      end
    end
  end

  context 'Device invalid' do
    before do
      expect_any_instance_of(Maia::Messenger).to receive(:connection) { GCM::UnregisteredDeviceTokenConnection.new('logan123') }
    end

    it 'destroys the device from the database' do
      message.send_to User.all
      expect(maia_devices(:john).reload).to be_persisted
      expect { maia_devices(:logan).reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context 'Device has canonical ID' do
    before do
      allow_any_instance_of(Maia::Messenger).to receive(:connection) { GCM::CanonicalIdConnection.new('logan123' => 'canonical123') }
    end

    it 'updates the device token to use a canonical ID if provided' do
      message.send_to User.all
      expect(maia_devices(:logan).reload.token).to eq 'canonical123'
    end

    it 'destroys the device if the user has another device registered with the same canonical ID' do
      users(:logan).devices.first.update token: 'canonical123'
      users(:logan).devices.create token: 'logan123'
      message.send_to users(:logan)
      expect(users(:logan).devices.count).to eq 1
      expect(users(:logan).devices.first.token).to eq 'canonical123'
    end
  end

  context 'GCM key is missing or invalid' do
    it 'raises an exception' do
      stub_request(:post, %r{gcm/send}).to_return body: '{}', status: 401
      expect { message.send_to user }.to raise_error(Maia::Error) do |e|
        expect(e.message).to eq 'Authentication error with GCM. Check the server whitelist and the validity of your project key.'
      end
    end
  end

  context 'GCM server times out' do
    it 'raises an exception' do
      stub_request(:post, %r{gcm/send}).to_return body: '{}', status: 500
      expect { message.send_to user }.to raise_error(Maia::Error) do |e|
        expect(e.message).to eq 'GCM Internal server error.'
      end
    end
  end
end
