class Credential < ActiveRecord::Base
  belongs_to :member
  belongs_to :email
  has_many :permissions
  has_many :api_tokens

  def self.authenticate(address, password)
    authenticated = nil

    if address.present?
      email = Email.find_by(address: Email.canonicalize_address(address))
      if email
        creds = self.where(email: email)

        # If there are multiple credentials, see if any of them are the right one.
        creds.each do |cred|
          if cred.password == password
            authenticated = cred
            break
          end
        end
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
    member = Member.create(person: person)
    
    self.create(email: email, password: password, member: member)
  end

  # User in the hash is already externally authenticated by facebook, google+, etc.
  # Credential.authenticate_oauth finds or creates a Jammcard credential that matches
  # the email address of the authenticated user.  If a user has authenticated once with
  # facebook, and then they want to authenticate with google+, we allow that, but ignore
  # the new provider.  This probably requires more thought.
  def self.authenticate_oauth(hash)
    email = Email.find_or_create_by(:address => hash[:email])
    existing_member = email.member
    cred = self.find_or_create_by(email: email, provider: hash[:provider], uid: hash[:uid])
    
    # Make up a password: but only if there isn't already one there!
    cred.password ||= SecureRandom.hex(30)
    cred.member ||= existing_member
    cred.save

    if not cred.member
      person = Person.create(hash[:person].slice(:fname, :lname, :minitial, :birthdate))
      person.emails << email

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
  
  def as_json
    super(:only => [:id , :member_id , :created_at])
  end

  def to_s
    "#<Credential: #{self.id}: #{self.email.address}>"
  end
end
