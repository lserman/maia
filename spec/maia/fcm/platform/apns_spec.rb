describe Maia::FCM::Platform::APNS do
  subject { described_class.new message }

  let(:message) do
    double(badge: 1, sound: 'test.wav', priority: nil, background?: false)
  end

  describe '#badge' do
    it 'returns the message badge' do
      expect(subject.badge).to eq 1
    end
  end

  describe '#sound' do
    it 'returns the message sound' do
      expect(subject.sound).to eq 'test.wav'
    end
  end

  describe '#priority' do
    it 'is 5 by default' do
      expect(subject.priority).to eq 5
    end

    it 'can be set to high' do
      expect(message).to receive(:priority) { :high }
      expect(subject.priority).to eq 10
    end

    it 'is 5 on a background message no matter what' do
      expect(message).to receive(:background?) { true }
      expect(message).to receive(:priority) { :high }
      expect(subject.priority).to eq 5
    end
  end

  describe '#to_h' do
    it 'serializes as an FCM IOSConfig object' do
      expect(subject.to_h).to eq({
        headers: {
          'apns-priority': '5',
        },
        payload: {
          aps: {
            badge: 1,
            sound: 'test.wav'
          }
        }
      })
    end

    it 'includes content-available if the message is backgrounded' do
      expect(message).to receive(:background?) { true }
      expect(subject.to_h[:payload][:aps][:'content-available']).to eq 1
    end
  end
end
