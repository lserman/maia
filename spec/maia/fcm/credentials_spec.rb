describe Maia::FCM::Credentials do
  describe '#project' do
    it 'returns the project ID from the credentials file' do
      expect(subject.project).to eq 'maia'
    end
  end

  describe '#token' do
    before do
      Rails.cache.clear
    end

    it 'fetches the access token from the googleauth gem and caches it' do
      creds = double(:creds)
      expect(creds).to receive(:fetch_access_token!).once { Hash['access_token' => 'token123'] }
      expect(Google::Auth::ServiceAccountCredentials).to receive(:make_creds) { creds }

      # 2 times to ensure the `once` matcher works. Need to assert it is pulled from cache.
      2.times { expect(subject.token).to eq 'token123' }
    end

    it 're-fetches when cache does not contain the token' do
      creds = double(:creds)
      expect(creds).to receive(:fetch_access_token!).twice { Hash['access_token' => 'token123'] }
      expect(Google::Auth::ServiceAccountCredentials).to receive(:make_creds) { creds }
      expect(subject.token).to eq 'token123'
      Rails.cache.clear
      expect(subject.token).to eq 'token123'
    end
  end

  describe '#to_h' do
    it 'returns a hash version of the credentials file' do
      %w(
        type
        project_id
        private_key_id
        private_key
        client_email
        client_id
        auth_uri
        token_uri
        auth_provider_x509_cert_url
        client_x509_cert_url
      ).each do |key|
        expect(subject.to_h).to include key
      end

    end
  end
end
