$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "generic_people_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name        = "generic_people_rails"
  s.version     = GenericPeopleRails::VERSION
  s.authors     = ["Daniel Staudigel", "Brian J. Fox"]
  s.email       = ["developer@opuslogica.com"]
  s.homepage    = "http://github.com/opuslogica/generic-people-rails"
  s.summary     = "Models and migrations for a membership network."
  s.description = "Creates all of the models and migrations for a full featured application that features members that are mostly people, including multiple and labeled forms of contact, credentials, credential providers, and the like."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  # s.add_runtime_dependency "rails", "~> 5"
  s.add_runtime_dependency "foreigner", "~> 1.6.1"
  s.add_runtime_dependency "forgery"
  s.add_runtime_dependency "geocoder"
  s.add_runtime_dependency "zodiac"
  s.add_runtime_dependency "carmen"
  s.add_runtime_dependency "carmen-demonyms"
  s.add_runtime_dependency "bcrypt"
  s.add_development_dependency "sqlite3"
end
