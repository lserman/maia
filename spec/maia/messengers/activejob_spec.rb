describe Maia::Messengers::ActiveJob do
  it 'enqueues a job to deliver the payload' do
    expect { subject.deliver 123 }
      .to enqueue_job(Maia::Messengers::ActiveJob::MessengerJob).with(123)
  end

  describe Maia::Messengers::ActiveJob::MessengerJob do
    it 'uses the inline gateway to send the payload' do
      messenger = double :messenger
      expect(Maia::Messengers::Inline).to receive(:new) { messenger }
      expect(messenger).to receive(:deliver).with 123
      subject.perform 123
    end
  end
end
