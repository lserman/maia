ENV['RAILS_ENV'] ||= 'test'
ENV['GOOGLE_APPLICATION_CREDENTIALS'] = File.join(__dir__, 'support', 'service-account.json')

require File.expand_path('../../spec/dummy/config/environment.rb', __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../../spec/dummy/db/migrate', __FILE__)]

require 'rspec/rails'
require 'webmock/rspec'
require 'pry'

ActiveRecord::Migration.maintain_test_schema!
ActiveJob::Base.queue_adapter = :test

RSpec.configure do |config|
  config.global_fixtures = :all
  config.fixture_path = File.expand_path('../fixtures', __FILE__)
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  webmock = Module.new do
    def webmock(filename, status = 200)
      response = File.read File.join(__dir__, 'support', 'stubs', filename)
      WebMock.stub_request(:post, /fcm/).to_return status: status, body: response
    end
  end

  config.include webmock

  config.before do
    Maia.messenger = Maia::Messengers::Inline.new
    @request.try { |req| req.env['HTTP_ACCEPT'] = 'application/json' }
  end
end
