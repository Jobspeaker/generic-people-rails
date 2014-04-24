class Member < ActiveRecord::Base
  belongs_to :person
  has_many :credentials
end
