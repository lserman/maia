describe Maia::FCM::ResponseCollection do
  subject { described_class.new notification, [response1, response2] }
  let(:notification) { double :notification }

  let(:response1) do
    json = File.read File.join(__dir__, '..', '..', 'support', 'stubs', 'POST_success_multicast.200.json')
    Maia::FCM::Response.new double(body: json, status: 200), [1, 2, 3]
  end

  let(:response2) do
    json = File.read File.join(__dir__, '..', '..', 'support', 'stubs', 'POST_success.200.json')
    Maia::FCM::Response.new double(body: json, status: 200), [4]
  end

  describe '#results' do
    it 'flat maps the response results into a result collection' do
      expect(subject.results.count).to eq 4
      expect(subject.results[0].token).to eq 1
      expect(subject.results[1].token).to eq 2
      expect(subject.results[2].token).to eq 3
      expect(subject.results[3].token).to eq 4
    end
  end

  describe '#[]' do
    it 'returns the response at the given index' do
      expect(subject[0]).to eq response1
      expect(subject[1]).to eq response2
    end
  end

  describe '#<<' do
    it 'adds a response to the responses' do
      response3 = double :response3
      subject << response3
      expect(subject[2]).to eq response3
    end
  end
end
