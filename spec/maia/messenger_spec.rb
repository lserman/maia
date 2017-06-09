describe Maia::Messenger do
  it 'sends the message to FCM' do
    stub_request(:post, Maia::FCM::Connection::URL).to_return body: '{}', status: 200
    subject.perform 'token123', 'title' => 'Test'
    expect(WebMock).to have_requested(:post, Maia::FCM::Connection::URL)
  end

  context 'FCM error' do
    let(:device) { maia_devices(:logan) }

    %w(InvalidRegistration NotRegistered MismatchSenderId).each do |error|
      it "destroys the device if #{error}" do
        webmock "POST_#{error}.200.json"
        subject.perform device.token, 'title' => 'Test'
        expect { device.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  context 'Canonical IDs' do
    let(:device) { maia_devices(:logan) }

    it "destroys the device if the user has registered it under it's canonical ID already" do
      webmock 'POST_CanonicalIds.200.json'
      device.pushable.devices.create token: 'canonical123'
      expect {
        subject.perform device.token, 'title' => 'Test'
      }.to change(Maia::Device, :count).by(-1)
    end

    it 'updates the device token to be the canonical ID' do
      webmock 'POST_CanonicalIds.200.json'
      expect {
        subject.perform device.token, 'title' => 'Test'
      }.to change {
        device.reload.token
      }.from('logan123').to 'canonical123'
    end
  end
end
