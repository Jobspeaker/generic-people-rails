class Email < ActiveRecord::Base
  belongs_to :label
  has_and_belongs_to_many :people
  has_many :credentials, dependent: :destroy

  validates_uniqueness_of :address, message: "Already exists."
  validates_format_of :address, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create
  
  before_validation :canonicalize_address

  def admin_object_name
    self.address
  end

  def person
    self.people.first rescue nil
  end

  def member
    p = person
    m = p.member if p.present?
    m
  end

  def self.canonicalize_address(addr)
    addr.strip if not addr.blank?
  end

  def canonicalize_address
    self.address = self.class.canonicalize_address(self.address)
  end

  def label=(text_or_label)
    l   = Label.get(text_or_label.to_s) if text_or_label.is_a?(String) or text_or_label.is_a?(Symbol)
    l ||= text_or_label
    write_attribute(:label_id, l.id)
  end

  def as_json(options={})
    for_member = options.delete(:for_member)
    res = super(options)
    res[:label] = self.label.value if self.label.present?
    res
  end
end
