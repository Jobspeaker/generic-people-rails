require 'bcrypt'
class Credential < ActiveRecord::Base
  include BCrypt
    
  belongs_to :member
  has_many :api_tokens, dependent: :destroy

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
            
            # this is here because if someone signs up, then connects the same
            # email using facebook, they have to use their original password
            # to connect and now we need to link their other creds to the right member
            # account.
            cred.email.credentials.update_all(member_id: cred.member.id)
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
    cred = nil
    person = nil
    member = nil
    email = Email.find_by(address: address)
    return [nil, "Account already exists. Please log in"] if email
    
    email = Email.new(address: address)
    return [nil, email.errors.full_messages.to_sentence] if !email.valid?

    send_mail = (hash[:send_mail].present? && hash[:send_mail] == "true") ? true : false

    # Validate person details, strong params.
    if hash.respond_to?(:permit)
      person_params = hash.permit(:name, :birthdate, :fname, :lname, :minitial)
    else
      person_params = hash.slice(:name, :birthdate, :fname, :lname, :minitial)
    end
    person = email.person rescue nil
    person ||= Person.new(person_params)
    return [nil, person.errors.full_messages.to_sentence] if !person.valid?

    # Make all creations atomic where possible.
    Member.transaction do
      # Check to see if this email is already in use.
      e = email if email.id
      member = e.member if e

      # If in use, and there are any credential records, try to authenticate.
      if e and  self.find_by(email: e)
        msg = nil
        cred = self.authenticate(address, password)

        if not cred
          # Try hard to understand what's happening.  If the user has signed up via linkedIn or Facebook,
          # and then is re-signing up, let's tell them to login using those services.
          creds = self.where(email: e)
          has_pass = nil
          providers = []
          creds.each do |c|
            if c.password or (c.respond_to?(:salt) and c.salt)
              has_pass = c
              break
            else 
              providers.push c.provider if c.provider
            end
          end

          msg = "Password doesn't match existing user" if has_pass
          msg = "You've never used a password - login with " + providers.to_sentence(two_words_connector: ' or ', last_word_connector: ', or ') if not providers.empty?
          return [cred, msg]
        end
      end
      email.save if not email.id
      person.emails << email if not person.emails.include?(email)
      person.save
      member = Member.create(person_id: person.id, status: GenericPeopleRails::Config.default_member_status) if not member
    end
        
    cred ||= self.create(email: email, password: password, member: member, uid: SecureRandom.uuid) if member and member.id
    (cred.send_welcome rescue nil) if cred && send_mail
    [cred, cred ? cred.errors.full_messages.to_sentence : nil]
  end

  # User in the hash is already externally authenticated by facebook, google+, etc.
  # Credential.authenticate_oauth finds or creates a credential that matches
  # the oauth token of the authenticated user.  If a user has authenticated once with
  # facebook, and then they want to authenticate with google+, we allow that.
  # Need to allow to return error messages
  # So returns array
  # [object, errors]
  def self.authenticate_oauth(hash)
    return [nil, "incorrect credentials: :hash[:uid] not set"] if hash[:uid].blank?
    return [nil, "incorrect credentials: :hash[:provider] is not set"] if hash[:provider].blank?
    
    send_mail = (hash[:send_mail].present? && hash[:send_mail] == "true") ? true : false
    
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
              #return [nil, "An account already exists with this email address."]
              cred.update_attribute(:member_id, other_crd.member_id)
              break
            end
          end
        end
        if !cred.member 
          # if still here, ok to create- only gets name from weblogin 
          person_hash = {person: {name: hash[:name]}}
          person = Person.create(person_hash[:person].slice(:name))
          person.emails << email if email

          member = Member.create(person: person, status: GenericPeopleRails::Config.active_status)
          cred.member = member
          cred.save
          cred.send_welcome if send_mail
        end
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
  
  def send_welcome
    if self.member.credentials.length == 1 && defined?(ActionMailer) && GenericPeopleRails::Config.send_welcome 
      GprMailer.welcome(self.member, self).deliver  
    end
  end
   
end
