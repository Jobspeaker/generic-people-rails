class Permission < ActiveRecord::Base
  belongs_to :credential
  belongs_to :permission_label

  def self.lookup(name)
    candidates = self.joins(:permission_label).includes(:permission_label).where("permission_labels.name = ?", name)
    candidates[0] if candidates
  end
end
