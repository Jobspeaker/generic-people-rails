class Nickname < ActiveRecord::Base
  has_and_belongs_to_many :people
  has_and_belongs_to_many :clients

  def name
    self.moniker
  end
end
