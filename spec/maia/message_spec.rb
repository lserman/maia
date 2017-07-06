describe Maia::Message do
  describe '#send_to' do
    it 'does not enqueue any jobs if the pushable does not have any devices' do
      users(:logan).devices.delete_all
      expect { subject.send_to users(:logan) }.to_not enqueue_job
    end

    it 'queues a messenger job' do
      expect {
        subject.send_to users(:logan)
      }.to enqueue_job(Maia::Messenger)
    end

    it 'enqueues a messenger job for each platform' do
      users(:logan).devices.create token: 'ios123', platform: :ios
      users(:logan).devices.create token: 'android123', platform: :android
      users(:logan).devices.create token: 'unknown123', platform: nil
      expect {
        subject.send_to users(:logan)
      }.to enqueue_job(Maia::Messenger).thrice
    end

    it 'enqueues a messenger job for each batch' do
      stub_const 'Maia::BATCH_SIZE', 1
      users(:logan).devices.create token: 'ios2', platform: :ios
      expect {
        subject.send_to users(:logan)
      }.to enqueue_job(Maia::Messenger).twice
    end

    it 'batches the messenger jobs by platform' do
      stub_const 'Maia::BATCH_SIZE', 2
      users(:logan).devices.create token: 'ios2', platform: :ios
      users(:logan).devices.create token: 'ios3', platform: :ios
      expect {
        subject.send_to users(:logan)
      }.to enqueue_job(Maia::Messenger).twice
    end
  end

  %i(title body on_click icon badge color data).each do |prop|
    it 'is nil by default' do
      expect(subject.send(prop)).to be_nil
    end
  end

  describe '#sound' do
    it 'is default by default' do
      expect(subject.sound).to eq :default
    end
  end

  describe '#priority' do
    it 'is normal by default' do
      expect(subject.priority).to eq :normal
    end
  end

  describe '#content_available?' do
    it 'is false by default' do
      expect(subject).to_not be_content_available
    end
  end

  describe '#content_mutable?' do
    it 'is false by default' do
      expect(subject).to_not be_content_mutable
    end
  end

  describe '#dry_run?' do
    it 'is false by default' do
      expect(subject).to_not be_dry_run
    end
  end

  describe '#notification' do
    it 'contains the title' do
      expect(subject).to receive(:title) { 'Test' }
      expect(subject.notification[:title]).to eq 'Test'
    end

    it 'contains the body' do
      expect(subject).to receive(:body) { 'Test' }
      expect(subject.notification[:body]).to eq 'Test'
    end

    it 'contains the icon' do
      expect(subject).to receive(:icon) { 'test.png' }
      expect(subject.notification[:icon]).to eq 'test.png'
    end

    it 'contains the sound' do
      expect(subject).to receive(:sound) { :default }
      expect(subject.notification[:sound]).to eq 'default'
    end

    it 'contains the badge' do
      expect(subject).to receive(:badge) { 1 }
      expect(subject.notification[:badge]).to eq 1
    end

    it 'contains the color' do
      expect(subject).to receive(:color) { '#000000' }
      expect(subject.notification[:color]).to eq '#000000'
    end

    it 'contains the click_action' do
      expect(subject).to receive(:on_click) { 'test' }
      expect(subject.notification[:click_action]).to eq 'test'
    end
  end

  describe '#to_h' do
    it 'contains the priority' do
      expect(subject).to receive(:priority) { :normal }
      expect(subject.to_h[:priority]).to eq 'normal'
    end

    it 'contains the dry run status' do
      expect(subject).to receive(:dry_run?) { false }
      expect(subject.to_h[:dry_run]).to eq false
    end

    it 'contains the content available status' do
      expect(subject).to receive(:content_available?) { true }
      expect(subject.to_h[:content_available]).to eq true
    end

    it 'contains the content mutable status' do
      expect(subject).to receive(:content_mutable?) { true }
      expect(subject.to_h[:mutable_content]).to eq true
    end

    it 'contains the data' do
      expect(subject).to receive(:data) { Hash[one: 1, two: 2] }
      expect(subject.to_h[:data]).to eq Hash[one: 1, two: 2]
    end

    it 'contains the notification' do
      expect(subject).to receive(:notification) { Hash[one: 1, two: 2] }
      expect(subject.to_h[:notification]).to eq Hash[one: 1, two: 2]
    end
  end
end
