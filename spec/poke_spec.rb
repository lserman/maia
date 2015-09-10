describe 'Sending a test message (poke)' do
  let(:user) { users(:logan) }

  it 'sends the message via GCM' do
    stub_request(:post, %r[gcm/send]).to_return body: '{}', status: 200
    Maia::Poke.new.send_to user
    expect(WebMock).to have_requested(:post, 'https://android.googleapis.com/gcm/send').with body: {
      data: {},
      content_available: false,
      notification: {
        title: 'Poke',
        body: 'Poke',
        sound: 'default'
      },
      registration_ids: ['logan123']
    }.to_json
  end
end
