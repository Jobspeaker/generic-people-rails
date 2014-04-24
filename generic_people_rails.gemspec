$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "generic_people_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "generic_people_rails"
  s.version     = GenericPeopleRails::VERSION
  s.authors     = ["Daniel Staudigel", "Brian J. Fox"]
  s.email       = ["developer@opuslogica.com"]
  s.homepage    = "http://opuslogica.com/"
  s.summary     = "Models and migrations for a membership network."
  s.description = "Creates all of the models and migrations for a full featured application that features members that are mostly people, including multiple and labeled forms of contact, credentials, credential providers, and the like."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"
  s.add_runtime_dependency "foreigner", "~> 1.6.1"
  s.add_development_dependency "sqlite3"
end
