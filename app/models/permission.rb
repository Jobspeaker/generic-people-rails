class Permission < ActiveRecord::Base
  belongs_to :credential
  belongs_to :permission_label

  def self.lookup(name)
    candidates = self.joins(:permission_label).includes(:permission_label).where("permission_labels.name = ?", name)
    candidates[0] if candidates
  end

  def label=(str)
    self.permission_label = PermissionLabel.get(str)
  end

  def label
    permission_label.to_s rescue nil
  end

  def name
    permission_label.to_s rescue nil
  end

end
