describe Maia::Topic do
  subject { Maia::Topic.new('test') }

  describe '#to_s' do
    it do
      expect(subject.to_s).to eq 'test'
    end
  end

  describe '#to_h' do
    it do
      expect(subject.to_h).to eq(topic: 'test')
    end
  end

  describe '#each' do
    it 'enumerizes itself' do
      expect(subject.to_a).to eq [subject]
    end
  end
end
