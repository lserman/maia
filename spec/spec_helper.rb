ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../spec/dummy/config/environment.rb', __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../../spec/dummy/db/migrate', __FILE__)]

require 'rspec/rails'
require 'webmock/rspec'

ActiveRecord::Migration.maintain_test_schema!
ActiveJob::Base.queue_adapter = :test

RSpec.configure do |config|
  config.global_fixtures = :all
  config.fixture_path = File.expand_path('../fixtures', __FILE__)
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  webmock = Module.new do
    def webmock(filename)
      response = File.read File.join(__dir__, 'support', 'stubs', filename)
      WebMock.stub_request(:post, Maia::FCM::Connection::URL).to_return status: 200, body: response
    end
  end

  config.include webmock

  config.before do
    @request.try { |req| req.env['HTTP_ACCEPT'] = 'application/json' }
  end
end
