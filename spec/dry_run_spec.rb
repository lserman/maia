describe 'Sending a dry run' do
  let(:user) { users(:logan) }

  it 'sends the message via GCM with dry_run=true' do
    stub_request(:post, %r[gcm/send]).to_return body: '{}', status: 200
    Maia::DryRun.new.send_to user
    expect(WebMock).to have_requested(:post, 'https://android.googleapis.com/gcm/send').with body: {
      data: {},
      notification: {
        title: '',
        body: '',
        sound: 'default'
      },
      dry_run: true,
      registration_ids: ['logan123']
    }.to_json
  end
end
