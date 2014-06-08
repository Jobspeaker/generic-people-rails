class Email < ActiveRecord::Base
  belongs_to :label
  has_and_belongs_to_many :people

  before_save :force_address_to_lowercase

  def admin_object_name
    self.address
  end

  def person
    self.people.first rescue nil
  end

  def force_address_to_lowercase
    self.address = self.address.downcase if self.address.present?
  end
end
