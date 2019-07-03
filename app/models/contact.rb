class Contact < ActiveRecord::Base
  belongs_to :person, optional: true
  belongs_to :label, optional: true
  accepts_nested_attributes_for :label

  delegate :fname, :to => :person, :allow_nil => true
  delegate :lname, :to => :person, :allow_nil => true
  delegate :minitial, :to => :person, :allow_nil => true
  delegate :name, :to => :person, :allow_nil => true
  delegate :monikers, :to => :person, :allow_nil => true
  delegate :email, :to => :person, :allow_nil => true
  delegate :email=, :to => :person, :allow_nil => true
  delegate :address, :to => :person, :allow_nil => true
  delegate :address=, :to => :person, :allow_nil => true
  delegate :phone, :to => :person, :allow_nil => true
  delegate :phone=, :to => :person, :allow_nil => true

#  has_many :nicknames, :through => :person

end
