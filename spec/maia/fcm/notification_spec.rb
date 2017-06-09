describe Maia::FCM::Notification do
  subject { described_class.new attributes }
  let(:attributes) { { one: 1, two: 2 } }

  describe '#to_h' do
    it 'returns the attributes' do
      expect(subject.to_h).to eq attributes
    end
  end

  describe '#==' do
    it 'returns true if the other object has the same attribute' do
      expect(subject).to eq double(attributes: attributes)
    end
  end

  describe '#method_missing' do
    it 'delegates method calls to the attributes hash' do
      expect(subject.one).to eq 1
      expect(subject.two).to eq 2
      expect { subject.three }.to raise_error NoMethodError
    end
  end
end
