describe Maia::Messengers::Inline do
  let(:gateway) do
    Class.new do
      def payload; @payload; end

      def deliver(payload)
        @payload = payload
      end
    end.new
  end

  it 'delivers the payload through the gateway' do
    subject.deliver :test, gateway: gateway
    expect(gateway.payload).to eq :test
  end

  it 'deletes unregistered devices' do
    payload = { 'token' => maia_devices(:logan).token }.to_json

    error = Maia::Error::Unregistered.new
    error.payload = payload
    expect(gateway).to receive(:deliver).and_raise(error)

    expect { subject.deliver payload, gateway: gateway }.to raise_error(error)
    expect { maia_devices(:logan).reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
