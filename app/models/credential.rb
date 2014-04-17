class Credential < ActiveRecord::Base
  belongs_to :person
  belongs_to :email
  has_many :permissions
  has_many :api_tokens

  def self.authenticate(email, password)
    email_id = Email.find_by_address(email).id
    self.where(email_id: email_id, password: password).first if email_id
  end

  def can(name)
    self.permissions.where(permission_label: PermissionLabel.get(name)).first
  end

  def allow_to(name)
    self.permissions.find_or_create_by_permission_label_id(PermissionLabel.get(name).id)
  end

  def to_s
    "#<Credential: #{self.id}: #{self.email.address}>"
  end
end
