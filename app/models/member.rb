class Member < ActiveRecord::Base
  belongs_to :person
  has_many :credentials
  has_many :last_logins

  delegate :name, :to => :person
  delegate :human_name, :to => :person
  delegate :message_name, :to => :person
  delegate :location, :to => :person
  delegate :email, :to => :person
  delegate :set_location, :to => :person

  def update_last_login
    last_logins << LastLogin.create(:person => self, :moment => DateTime.now)
  end

end
