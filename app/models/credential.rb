require 'bcrypt'
class Credential < ActiveRecord::Base
  include BCrypt
    
  belongs_to :member
  has_many :api_tokens

  belongs_to :email
  accepts_nested_attributes_for :email

  has_many :permissions, dependent: :destroy
  accepts_nested_attributes_for :permissions
  
  def password
    if @password
      @password
    else
      if salt
        Password.new(salt)
      else 
        nil #hmmm happens with fb login...
      end
    end
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.salt = @password
  end

  def self.authenticate(address, password)
    authenticated = nil

    if address.present?
      emails = Email.where(address: address)
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
    if authenticated
      authenticated.member.update_last_login
    end
    authenticated
  end

  # Need to allow to return error messages
  # So returns array
  # [object, errors]  
  
  def self.sign_up(address, password, hash = {})
    Member.transaction do
      # validate email
      email = Email.new(address: address)
      return [nil, email.errors.full_messages.to_sentence] if !email.valid?
      # check if exists
      return [self.authenticate(address, password)] if Email.find_by(address: address)
      #validate person details
      person   = Person.new(hash.slice(:name, :birthdate)) if hash.has_key?(:name)
      person ||= Person.new(hash.slice(:fname, :lname, :minitial, :birthdate))    
      return [nil, person.errors.full_messages.to_sentence] if !person.valid?

      email.save
      person.emails << email
      person.save
      
      member = Member.create(person_id: person.id, status: GenericPeopleRails::Config.default_member_status)
      cred = self.create(email: email, password: password, member: member)
      cred.send_welcome
      [cred]      
    end
  end

  # User in the hash is already externally authenticated by facebook, google+, etc.
  # Credential.authenticate_oauth finds or creates a credential that matches
  # the oauth token of the authenticated user.  If a user has authenticated once with
  # facebook, and then they want to authenticate with google+, we allow that.
  # Need to allow to return error messages
  # So returns array
  # [object, errors]
  def self.authenticate_oauth(hash)
    return [nil, "incorrect credentials"] if hash[:uid].blank? or hash[:provider].blank?
    
    Member.transaction do
      email = Email.find_or_create_by(address: hash[:email]) # email required
      cred = self.find_or_create_by(uid: hash[:uid], provider: hash[:provider], email: email)
      
      # We have a credential, either new, or old.  If we have an email, set the email
      # in the credential.
      #cred.email = email if email
      # Make up a password: but only if there isn't already one there!
      cred.password ||= SecureRandom.hex(30)
      cred.save
    
      #check to see if member account exists for this email
      if not cred.member
        email.credentials.each do |other_crd|
          if other_crd != cred
            if !other_crd.member.nil?
              return [nil, "An account already exists with this email address."]
            end
          end
        end
        # if still here, ok to create- only gets name from weblogin 
        person_hash = {person: {name: hash[:name]}}
        person = Person.create(person_hash[:person].slice(:name))
        person.emails << email if email

        member = Member.create(person: person, status: GenericPeopleRails::Config.default_member_status)
        cred.member = member
        cred.save
        cred.send_welcome
      end

      [cred]
    end
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
  
  private
   def send_welcome
     if self.member.credentials.length == 1 && defined?(ActionMailer) && GenericPeopleRails::Config.send_welcome 
       GprMailer.welcome(self.member, self).deliver  
     end
   end
   
end
