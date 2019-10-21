describe Maia::FCM::Notification do
  subject { described_class.new message }

  let(:message) do
    double(:message, title: 'title', body: 'body', image: 'image')
  end

  describe '#title' do
    it 'returns the message title' do
      expect(subject.title).to eq 'title'
    end
  end

  describe '#body' do
    it 'returns the message body' do
      expect(subject.body).to eq 'body'
    end
  end

  describe '#image' do
    it 'returns the message image' do
      expect(subject.image).to eq 'image'
    end
  end

  describe '#to_h' do
    it 'returns the FCM serialization of a notification' do
      expect(subject.to_h).to eq({
        title: 'title',
        body: 'body',
        image: 'image'
      })
    end

    context 'nil attribute' do
      let(:message) do
        double(:message, title: 'title', body: 'body', image: nil)
      end

      it 'does not include nil attributes' do
        expect(subject.to_h).to eq({
          title: 'title',
          body: 'body'
        })
      end
    end
  end
end
