require "generic_people_rails/version"
require "generic_people_rails/engine"
require "generic_people_rails/config"

module GenericPeopleRails
  
  
  def self.config(&block)
    if block
      block.call(GenericPeopleRails::Config)
    else
      GenericPeopleRails::Config
    end
  end
end
