describe Maia::FCM::Response do
  subject { described_class.new double(body: json, code: status), tokens }

  let(:tokens) { [1, 2, 3] }
  let(:json) { File.read File.join(__dir__, '..', '..', 'support', 'stubs', 'POST_success_multicast.200.json') }

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

    describe '#results' do
      it 'returns a collection results' do
        expect(subject.results[0].token).to eq 1
        expect(subject.results[1].token).to eq 2
        expect(subject.results[2].token).to eq 3
      end
    end
  end

  describe 'failure' do
    describe '#error' do
      subject { super().error }

      context '400' do
        let(:status) { 400 }

        it 'is an invalid JSON error' do
          expect(subject).to include 'Invalid JSON'
        end
      end

      context '401' do
        let(:status) { 401 }

        it 'is an authentication error' do
          expect(subject).to include 'Authentication error'
        end
      end

      context '5xx' do
        let(:status) { 502 }

        it 'is an internal error' do
          expect(subject).to include 'Internal server error'
        end
      end
    end
  end
end
