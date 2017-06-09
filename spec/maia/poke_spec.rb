describe Maia::Poke do
  describe 'title' do
    it 'is present' do
      expect(subject.title).to be_present
    end
  end

  describe 'body' do
    it 'is present' do
      expect(subject.body).to be_present
    end
  end
end
