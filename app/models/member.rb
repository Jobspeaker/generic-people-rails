class Member < ActiveRecord::Base
  belongs_to :person

  has_many :credentials
  accepts_nested_attributes_for :credentials

  has_many :last_logins

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
end
