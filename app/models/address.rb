class Address < ActiveRecord::Base
  belongs_to :label
  has_and_belongs_to_many :people
  require 'carmen'
  require 'geocoder'

  def address
    oneline
  end

  def save(options={})
    r = super(options)
    @already_geocoded = false
    r
  end

  def assign_attributes(hash)
    if hash.has_key?('address')
      a = hash['address']
      hash.delete('address')
    end
    super(hash)
    self.address = a if a
    nil
  end

  def label=(text_or_label)
    l   = Label.get(text_or_label.to_s) if text_or_label.is_a?(String) or text_or_label.is_a?(Symbol)
    l ||= text_or_label
    write_attribute(:label_id, l.id)
  end

  def address=(string)
    return unless not string.blank? and not postal_changed?
    return unless string != line1
    return unless string != oneline

    r = Geocoder.search(string)
    @already_geocoded = true

    if r.length == 0
      self.errors[:address] = "No locations found."
      self.line1 = string
    else
      res = r[0]
      self.line1 = res.street_address.to_s
      self.line2 = nil
      self.city = res.city.to_s
      self.state = res.state_code.to_s
      self.postal = res.postal_code.to_s
      self.country = res.country_code.to_s
    end

    self.errors[:address] = "Too many matches." if r.length > 1
    self.oneline
  end

  def self.find_by_address(string)
    template = self.parse(string)
    self.find_by(template.attributes.symbolize_keys!.slice(:line1, :line2, :city, :state))
  end
  
  def as_json(options={})
    res = super(options)
    res[:address] = oneline
    res[:label] = self.label.value if self.label
    res
  end

  def update_from_postal
    return if @already_geocoded
    r = Geocoder.search(self.postal)
    if r.length == 0
      self.errors[:postal] = "Couldn't locate postal code"
    else
      res = r[0]
      self.city = res.city
      self.state = res.state_code
      self.country = res.country_code
    end
  end

  def admin_object_name
    [line1, city, postal].join(" ").strip rescue ""
  end

  def oneline
    "#{line1}, #{city}, #{state}"
  end

  def self.parse(string)
    a = self.new
    a.address = string
    a
  end

  def self.new_from_hash(incoming_hash)
    p = {}
    incoming_hash.each {|key, val| p[key] = val if not val.blank?}
    a = self.new
    a.line1 = p[:line1] || p[:address]
    a.line2 = p[:line2]
    a.city = p[:city]
    a.state = p[:state]
    a.country = p[:country]
    a.postal = p[:postal] || p[:zipcode] || p[:zip]
    a.label = Label.get("Work")
    a
  end

  def self.find_or_create_by_example(other)
    res = self
    res = res.where(:line1 => other.line1) if other.line1
    res = res.where(:line2 => other.line2) if other.line2
    res = res.where(:city => other.city) if other.city
    res = res.where(:state => other.state) if other.state
    res = res.where(:country => other.country) if other.country
    res = res.where(:postal => other.postal) if other.postal

    a = nil
    addresses = res
    if addresses != self
      a = Address.create(other.attributes.symbolize_keys!.except(:id, :created_at, :updated_at)) if addresses == []
      a ||= addresses[0]
    end

    a
  end

  def person
    self.people.first rescue nil
  end
end
