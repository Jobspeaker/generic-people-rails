class Phone < ActiveRecord::Base
  belongs_to :label, optional: true
  belongs_to :carrier, optional: true
  has_and_belongs_to_many :people

  before_validation :normalize_number
  #before_save :normalize_number
  
  def self.find_by_number(incoming)
    self.find_all_by_number(incoming).first
  end

  def self.find_all_by_number(incoming)
    number = self.format_number(incoming)
    self.where(:number => number)
  end

  def self.format_number(digits_and_stuff)
    formatted = digits_and_stuff
    formatted.gsub!(" ", "") #remove extra spaces
    if formatted
      formatted = formatted[2..100].strip if formatted.starts_with?("+1")
      if formatted[0] != "+"
        digits = digits_and_stuff.gsub(/[^0-9]/, "")
        digits = digits[1..-1] if digits[0] == '1'
        digits = "805" + digits if digits.length == 7
        formatted = "(#{digits[0..2]}) #{digits[3..5]}-#{digits[6..10]}"
      end
    end
    formatted
  end

  def normalize_number
    return if self.number == "76-BAFFLE-76"
    self.number = self.class.format_number(self.number) if self.number
  end

  def send_sms(message)
    self.carrier.send_sms(self.number, message)
  end

  def label=(text_or_label)
    l   = Label.get(text_or_label.to_s) if text_or_label.is_a?(String) or text_or_label.is_a?(Symbol)
    l ||= text_or_label
    Rails.logger.error("GPR:Model<phone>: text_or_label == '#{text_or_label}', class= '#{text_or_label.class.name}'") if not l
    write_attribute(:label_id, l.id) if l.present?
  end

  def as_json(options={})
    for_member = options.delete(:for_member)
    options[:only] ||= [:id, :number, :carrier, :created_at, :updated_at]
    res = super(options) if options.present?
    res[:label] = self.label.value if self.label
    res
  end

  def admin_object_name
    "#{number} (#{label.value rescue nil})"
  end

  def person
    self.people.first rescue nil
  end

end
