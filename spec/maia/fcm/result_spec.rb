describe Maia::FCM::Result do
  subject { described_class.new attributes, token }
  let(:token) { 'token123' }

  context 'success' do
    let(:attributes) { { message_id: 'message123', registration_id: 'canonical123' } }

    describe '#success?' do
      it 'returns true' do
        expect(subject).to be_success
      end
    end

    describe '#fail?' do
      it 'returns false' do
        expect(subject).to_not be_fail
      end
    end

    describe '#canonical_id' do
      it 'returns the registration ID' do
        expect(subject.canonical_id).to eq 'canonical123'
      end
    end

    describe '#has_canonical_id?' do
      it 'returns true if the canonical ID is present' do
        expect(subject).to be_has_canonical_id
      end

      it 'returns false if the canonical ID is present' do
        subject.registration_id = nil
        expect(subject).to_not be_has_canonical_id
      end
    end
  end

  context 'failure' do
    let(:attributes) { { error: 'Error' } }

    describe '#success?' do
      it 'returns false' do
        expect(subject).to_not be_success
      end
    end

    describe '#fail?' do
      it 'returns true' do
        expect(subject).to be_fail
      end
    end
  end
end
