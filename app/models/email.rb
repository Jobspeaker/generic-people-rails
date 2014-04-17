class Email < ActiveRecord::Base
  belongs_to :label
  has_and_belongs_to_many :people

  def admin_object_name
    self.address
  end

  def person
    self.people.first rescue nil
  end
end
