describe Maia::FCM::ResultCollection do
  subject { described_class.new [result1, result2, result3] }

  let(:result1) { double success?: true,  fail?: false, has_canonical_id?: false }
  let(:result2) { double success?: true,  fail?: false, has_canonical_id?: true }
  let(:result3) { double success?: false, fail?: true,  has_canonical_id?: false }

  describe '#succeeded' do
    it 'returns the results that were successful' do
      expect(subject.succeeded).to match_array [result1, result2]
    end
  end

  describe '#failed' do
    it 'returns the results that failed' do
      expect(subject.failed).to match_array [result3]
    end
  end

  describe '#with_canonical_ids' do
    it 'returns the results with canonical IDs' do
      expect(subject.with_canonical_ids).to match_array [result2]
    end
  end
end
