describe Maia::FCM::Response do
  subject { described_class.new double(body: json, code: status) }
  let(:stub) { 'fcm/success.json' }

  let(:json) do
    File.read File.join(__dir__, '..', '..', 'support', 'stubs', stub)
  end

  describe 'success' do
    let(:status) { 200 }

    describe '#status' do
      it 'returns the HTTP response code' do
        expect(subject.status).to eq 200
      end
    end

    describe '#success?' do
      it 'returns true for 200' do
        expect(subject).to be_success
      end

      it 'returns true for 399' do
        expect(subject).to receive(:status) { 399 }
        expect(subject).to be_success
      end

      it 'returns true for 400s' do
        expect(subject).to receive(:status) { 400 }
        expect(subject).to_not be_success
      end

      it 'returns true for 500s' do
        expect(subject).to receive(:status) { 500 }
        expect(subject).to_not be_success
      end
    end
  end

  describe 'failure' do
    let(:status) { 400 }

    describe '#fail?' do
      it 'returns true' do
        expect(subject).to be_fail
      end
    end

    describe '#error' do
      subject { super().error }

      context 'Unregistered token' do
        let(:stub) { 'fcm/UNREGISTERED.json' }

        it 'returns an Unregistered error' do
          expect(subject).to be_a_kind_of(Maia::Error::Unregistered)
        end
      end

      context 'Other error' do
        let(:stub) { 'fcm/INVALID_ARGUMENT.json' }

        it 'returns a generic error' do
          expect(subject).to be_a_kind_of(Maia::Error::Generic)
          expect(subject.message).to eq 'The registration token is not a valid FCM registration token'
        end
      end
    end
  end
end
