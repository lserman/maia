describe Maia::FCM::Connection do
  subject { described_class.new 'key123' }

  describe '#write' do
    it 'makes an HTTP post to FCM with the given payload' do
      webmock 'POST_success.200.json'
      subject.write 'test' => 'test'
      expect(WebMock).to have_requested(:post, described_class::URL).with({
        headers: { 'Content-Type' => 'application/json' },
        body: { 'test' => 'test' }
      })
    end
  end
end
