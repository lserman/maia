describe 'Sending a message with priority' do
  let(:user) { users(:logan) }

  before do
    stub_request(:post, %r[gcm/send]).to_return body: '{}', status: 200
  end

  it 'sends the message with normal priority by default' do
    TestMessage.new.send_to user
    expect(WebMock).to have_requested(:post, 'https://android.googleapis.com/gcm/send').with body: {
      data: { data: 123 },
      priority: 'normal',
      notification: {
        title: 'This is an alert',
        body: 'This is an alert',
        sound: 'default'
      },
      registration_ids: ['logan123']
    }.to_json
  end

  it 'sends the message with high priority' do
    TestMessage.new(priority: :high).send_to user
    expect(WebMock).to have_requested(:post, 'https://android.googleapis.com/gcm/send').with body: {
      data: { data: 123 },
      priority: 'high',
      notification: {
        title: 'This is an alert',
        body: 'This is an alert',
        sound: 'default'
      },
      registration_ids: ['logan123']
    }.to_json
  end
end
