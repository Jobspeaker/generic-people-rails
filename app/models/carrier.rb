class Carrier < ActiveRecord::Base

  def admin_object_name
    self.name
  end
end
