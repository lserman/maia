describe Maia::DryRun do
  describe 'title' do
    it 'is empty' do
      expect(subject.title).to be_empty
    end
  end

  describe 'body' do
    it 'is empty' do
      expect(subject.body).to be_empty
    end
  end

  describe 'dry_run?' do
    it 'is a dry run' do
      expect(subject).to be_dry_run
    end
  end
end
