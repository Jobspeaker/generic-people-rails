class Credential < ActiveRecord::Base
  belongs_to :person
  belongs_to :email
  has_many :permissions
  has_many :api_tokens

  def self.authenticate(email, password)
    email_object = Email.find_by_address(email)
    email_id = email_object.id if email_object
    self.where(email_id: email_id, password: password).first if email_id
  end

  def self.sign_up(email_address,password,hash = {})
    email_object = Email.find_by_address(email_address)
    return authenticate(email_address,password) if email_object && self.where(email_id: email_object.id).length

    email = Email.find_or_create_by(address: email_address)
    self.create(email: email,password: password)
  end

  def self.authenticate_oauth(hash)
    email_id = Email.find_or_create_by(:address => hash[:email]).id
    c = self.find_by(email_id:email_id, provider: hash[:provider] , uid: hash[:uid])
    c ||= self.create(email_id:email_id, provider: hash[:provider], uid: hash[:uid], password: SecureRandom.hex(30))
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
