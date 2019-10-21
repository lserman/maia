describe Maia::FCM::Connection do
  subject { described_class.new('test', 'test-token') }

  describe '#write' do
    it 'makes an HTTP post to FCM with the given payload' do
      webmock 'fcm/success.json'
      subject.write({ test: 'test' }.to_json)

      expect(WebMock).to have_requested(:post, %r{projects/test/messages:send$}).with({
        headers: {
          'Content-Type' => 'application/json',
          'Authorization' => 'Bearer test-token'
        },
        body: {
          'test' => 'test'
        }
      })
    end
  end
end
