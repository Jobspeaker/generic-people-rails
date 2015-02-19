class Member < ActiveRecord::Base
  alias :super_destroy :destroy
  
  belongs_to :person, dependent: :destroy
  accepts_nested_attributes_for :person

  has_many :credentials, dependent: :destroy
  accepts_nested_attributes_for :credentials

  has_many :last_logins, dependent: :destroy

  delegate :name, :to => :person, :allow_nil => true
  delegate :fname, :to => :person, :allow_nil => true
  delegate :lname, :to => :person, :allow_nil => true
  delegate :minitial, :to => :person, :allow_nil => true
  delegate :prefix, :to => :person, :allow_nil => true
  delegate :suffix, :to => :person, :allow_nil => true
  delegate :human_name, :to => :person , :allow_nil => true
  delegate :message_name, :to => :person, :allow_nil => true
  delegate :location, :to => :person, :allow_nil => true
  delegate :email, :to => :person, :allow_nil => true
  delegate :set_location, :to => :person, :allow_nil => true

  before_save :ensure_uuid

  def update_last_login
    last_logins << LastLogin.create(:member => self, :moment => DateTime.now)
  end

  def make_uuid
    SecureRandom.uuid.downcase
  end

  def ensure_uuid
    (self.uuid = make_uuid if not self.uuid.present?) rescue nil
  end
  
  # checks to see if account has been destroyed. 
  # only useful if using acts_paranoid
  def is_cancelled?
    !self.deleted_at.nil?
  end
    
  #overrides destroy to preserve data
  # use acts_paranoid config to change behavior
  def destroy
    if GenericPeopleRails::Config.acts_paranoid
      self.update(deleted_at: Time.now, status: GenericPeopleRails::Config.cancelled_status)
    else
      self.super_destroy
    end
  end
  
  #final kill - way to work around acts_paranoid for administrators
  def kill
    self.super_destroy
    # kill email too. 
    self.email.destroy
  end

end
