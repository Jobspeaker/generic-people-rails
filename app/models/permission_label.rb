class PermissionLabel < ActiveRecord::Base
  def self.instantiate_defaults
    ["Admin Any Invoice", "Admin Own Hours", "Admin Any Client", "Admin Own Clients",
     "View Any Invoice", "View Own Invoice", "View Any Client", "View Own Client",
     "Admin Any Rate", "Admin Own Rate", "View Any Rate", "View Own Rate"].each {|n| self.get(n)}
  end

  def self.get(name)
    sym  = name if name.class == Symbol
    sym ||= name.to_s.strip.gsub(/[- \t]+/, "_").downcase.to_sym
    l = self.where(:name => sym)[0] rescue nil
    l ||= self.create(:name => sym)
    l
  end

  def to_s
    name.to_s.gsub(/_/," ").capitalize
  end
end
