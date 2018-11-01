class Device < ActiveRecord::Base
  belongs_to :person
  
  # for integration with other systems
  def user_id=(user_id)
    person_id = user_id
  end
  
  def user_id
    person_id
  end
  
end
