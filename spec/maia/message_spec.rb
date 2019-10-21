describe Maia::Message do
  %i(title body image badge color priority).each do |prop|
    it 'is nil by default' do
      expect(subject.send(prop)).to be_nil
    end
  end

  describe '#sound' do
    it 'is default by default' do
      expect(subject.sound).to eq 'default'
    end
  end

  describe '#background?' do
    it 'is falsey by default' do
      expect(subject).to_not be_background
    end
  end

  describe '#targeting' do
    it 'returns itself with the target set' do
      message = subject.targeting(:test)
      expect(message.instance_variable_get('@target')).to eq :test
    end
  end

  describe '#send_to' do
    let(:messenger) { Maia::Messengers::Array.new }

    it 'sends to a topic' do
      subject.send_to topic: 'test', messenger: messenger
      message = messenger.first
      expect(message['message']['topic']).to eq 'test'
    end

    it 'sends to a token' do
      subject.send_to token: 'test', messenger: messenger
      message = messenger.first
      expect(message['message']['token']).to eq 'test'
    end

    it 'sends to a device' do
      subject.send_to users(:logan), messenger: messenger
      message = messenger.first
      expect(message['message']['token']).to eq 'logan123'
    end

    it 'sends to a token and a topic at once' do
      subject.send_to topic: 'topic', messenger: messenger
      subject.send_to token: 'token', messenger: messenger
      expect(messenger.to_a[0]['message']['topic']).to eq 'topic'
      expect(messenger.to_a[1]['message']['token']).to eq 'token'
    end
  end
end
