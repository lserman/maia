describe 'Sending a message with priority' do
  let(:user) { users(:logan) }

  before do
    stub_request(:post, %r[gcm/send]).to_return body: '{}', status: 200
  end

  it 'sends the message with high priority' do
    TestMessage.new(priority: :high).send_to user
    expect(WebMock).to have_requested(:post, 'https://android.googleapis.com/gcm/send')
      .with body: hash_including(priority: 'high')
  end
end
