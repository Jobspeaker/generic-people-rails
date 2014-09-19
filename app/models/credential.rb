class Credential < ActiveRecord::Base
  belongs_to :member
  has_many :api_tokens

  belongs_to :email
  accepts_nested_attributes_for :email

  has_many :permissions
  accepts_nested_attributes_for :permissions

  def self.authenticate(address, password)
    authenticated = nil

    if address.present?
      emails = Email.where(address: Email.canonicalize_address(address))
      emails.each do |email|
        creds = self.where(email: email)

        # If there are multiple credentials, see if any of them are the right one.
        creds.each do |cred|
          if cred.password == password
            authenticated = cred
            break
          end
        end
        break if authenticated
      end
    end
    authenticated
  end

  def self.sign_up(address, password, hash = {})
    address = Email.canonicalize_address(address)
    return false if not address.present?
    return self.authenticate(address, password) if Email.find_by(address: address)
    email = Email.create(address: address)
    person   = Person.create(hash.slice(:name, :birthdate)) if hash.has_key?(:name)
    person ||= Person.create(hash.slice(:fname, :lname, :minitial, :birthdate))
    person.emails << email
    Rails.logger.info("CREDENTIAL: SIGNUP: BEFORE MEMBER CALL, person: #{person}")
    member = Member.create(person_id: person.id)
    Rails.logger.info("CREDENTIAL: SIGNUP: AFTER MEMBER CALL, member: #{member}")
    
    self.create(email: email, password: password, member: member)
  end

  # User in the hash is already externally authenticated by facebook, google+, etc.
  # Credential.authenticate_oauth finds or creates a Jammcard credential that matches
  # the oauth token of the authenticated user.  If a user has authenticated once with
  # facebook, and then they want to authenticate with google+, we allow that.
  def self.authenticate_oauth(hash)
    return false if hash[:uid].blank? or hash[:provider].blank?
    cred = self.find_or_create_by(uid: hash[:uid], provider: hash[:provider])
    email = Email.find_or_create_by(address: hash[:email]) if not hash[:email].blank?

    # We have a credential, either new, or old.  If we have an email, set the email
    # in the credential.
    cred.email = email if email
    cred.save

    # Make up a password: but only if there isn't already one there!
    cred.password ||= SecureRandom.hex(30)
    cred.save

    if not cred.member
      person = Person.create(hash[:person].slice(:fname, :lname, :minitial, :birthdate))
      person.emails << email if email

      member = Member.create(person: person)
      cred.member = member
      cred.save
    end

    cred
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

  def as_json(options={})
    super(:only => [:id, :member_id, :created_at])
  end
end
