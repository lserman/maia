describe Maia::FCM::Platform::Android do
  subject { described_class.new message }

  let(:message) do
    double(color: 'red', sound: 'test.wav', priority: nil)
  end

  describe '#color' do
    it 'returns the message color' do
      expect(subject.color).to eq 'red'
    end
  end

  describe '#sound' do
    it 'returns the message sound' do
      expect(subject.sound).to eq 'test.wav'
    end
  end

  describe '#priority' do
    it 'is normal by default' do
      expect(subject.priority).to eq :normal
    end

    it 'can be set to high' do
      expect(message).to receive(:priority) { :high }
      expect(subject.priority).to eq :high
    end
  end

  describe '#to_h' do
    it 'serializes as an FCM AndroidConfig object' do
      expect(subject.to_h).to eq({
        priority: 'normal',
        notification: {
          color: 'red',
          sound: 'test.wav'
        }
      })
    end
  end
end
