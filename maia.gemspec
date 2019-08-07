$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'maia/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'maia'
  s.version     = Maia::VERSION
  s.authors     = ['Logan Serman']
  s.email       = ['loganserman@gmail.com']
  s.homepage    = 'https://github.com/lserman/maia'
  s.summary     = 'Manage device tokens and push messaging with Rails and FCM.'
  s.description = s.summary
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', ['>= 5', '< 6']
  s.add_dependency 'activejob', ['>= 5', '< 6']
  s.add_dependency 'responders'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'webmock-rspec-helper'
end
