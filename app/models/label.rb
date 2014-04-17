class Label < ActiveRecord::Base

  def self.instantiate_defaults
    %w(Home Work Cell).each {|v| self.get(v)}
  end

  def self.get(name)
    l = self.where(:value => name)[0] rescue nil
    l ||= self.create(:value => name)
    l
  end

  def admin_object_name
    self.value
  end
end
