class Email < ActiveRecord::Base
  belongs_to :label
  has_and_belongs_to_many :people

  before_save :force_address_to_lowercase

  def admin_object_name
    self.address
  end

  def person
    self.people.first rescue nil
  end

  def force_address_to_lowercase
    self.address = self.address.downcase if self.address.present?
  end

  def label=(text_or_label)
    l   = Label.get(text_or_label.to_s) if text_or_label.is_a?(String) or text_or_label.is_a?(Symbol)
    l ||= text_or_label
    write_attribute(:label_id, l.id)
  end

  def as_json(options={})
    for_member = options.delete(:for_member)
#    includes = options.delete(:include)
    res = super(options)
    res[:label] = self.label.value if self.label.present?
    res
  end
end
