class Nickname < ActiveRecord::Base
  has_and_belongs_to_many :people

  def name
    self.moniker
  end
end
