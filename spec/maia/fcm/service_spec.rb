describe Maia::FCM::Service do
  describe '#key' do
    it 'uses the FCM_KEY environment variable by default' do
      ENV['FCM_KEY'] = 'key123'
      expect(subject.key).to eq 'key123'
    end

    it 'fallsback to Maia::FCM.key' do
      Maia::FCM.key = 'key123'
      expect(subject.key).to eq 'key123'
    end
  end

  describe '#deliver' do
    before { webmock 'POST_success.200.json' }

    it 'uses the to: FCM param when sending to one token' do
      subject.deliver Hash[title: 'Test'], 'token123'
      expect(WebMock).to have_requested(:post, /fcm/).with body: hash_including(to: 'token123')
    end

    it 'uses the registration_ids: FCM param when sending to multiple tokens' do
      subject.deliver Hash[title: 'Test'], %w(token1 token2)
      expect(WebMock).to have_requested(:post, /fcm/).with body: hash_including(registration_ids: %w(token1 token2))
    end

    it 'uses the topic: FCM param when sending to a topic' do
      subject.deliver Hash[title: 'Test'], topic: 'test-123'
      expect(WebMock).to have_requested(:post, /fcm/).with body: hash_including(topic: 'test-123')
    end

    it 'calls the FCM API in batches' do
      stub_const 'Maia::BATCH_SIZE', 2
      subject.deliver Hash[title: 'Test'], %w(token1 token2 token3 token4 token5)
      expect(WebMock).to have_requested(:post, /fcm/).with body: hash_including(registration_ids: %w(token1 token2))
      expect(WebMock).to have_requested(:post, /fcm/).with body: hash_including(registration_ids: %w(token3 token4))
      expect(WebMock).to have_requested(:post, /fcm/).with body: hash_including(to: 'token5')
    end
  end
end
