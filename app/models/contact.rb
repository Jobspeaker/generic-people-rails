class Contact < ActiveRecord::Base
  belongs_to :person
  belongs_to :label

  delegate :fname, :to => :person
  delegate :lname, :to => :person
  delegate :minitial, :to => :person
  delegate :name, :to => :person, :allow_nil => true
  delegate :monikers, :to => :person
  delegate :email, :to => :person
  delegate :email=, :to => :person
  delegate :address, :to => :person
  delegate :address=, :to => :person
#  has_many :nicknames, :through => :person

end
