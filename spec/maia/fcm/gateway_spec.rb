describe Maia::FCM::Gateway do
  subject { described_class.new auth }
  let(:auth) { double(project: 'test', token: 'token123') }

  describe '#deliver' do
    it 'sends the payload via the FCM connection with' do
      webmock 'fcm/success.json'
      subject.deliver Hash[title: 'Test'].to_json

      expect(WebMock)
        .to have_requested(:post, /fcm/)
        .with body: hash_including(title: 'Test')
    end

    it 'raises the response error if it failed' do
      webmock 'fcm/UNREGISTERED.json', 400
      expect {
        subject.deliver('{}')
      }.to raise_error(Maia::Error::Unregistered)
    end
  end

  describe '#serialize' do
    it 'returns the FCM JSON fort he given message/target' do
      json = subject.serialize Maia::Poke.new, Maia::Token.new('token123')
      hash = JSON.parse json
      expect(hash['message']['notification']['title']).to eq 'Poke!'
      expect(hash['message']['token']).to eq 'token123'
    end
  end
end
