class Phone < ActiveRecord::Base
  belongs_to :label
  belongs_to :carrier
  has_and_belongs_to_many :people

  before_save :normalize_number
  
  def assign_attributes(hash)
    hash[:label] = Label.get(hash[:label]) if hash[:label].kind_of? String
    super(hash)
  end
  
  def self.find_by_number(incoming)
    self.find_all_by_number(incoming).first
  end

  def self.find_all_by_number(incoming)
    number = self.format_number(incoming)
    self.where(:number => number)
  end

  def self.format_number(digits_and_stuff)
    formatted = digits_and_stuff
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
    self.number = self.class.format_number(self.number) if self.number
  end

  def send_sms(message)
    self.carrier.send_sms(self.number, message)
  end

  def as_json(options=nil)
    res = super(:only => [:id, :number, :carrier, :created_at, :updated_at])
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
