class Address < ActiveRecord::Base
  belongs_to :label
  has_and_belongs_to_many :people

  before_validation :update_from_postal , :if => lambda { |obj| obj.postal_changed? }

  def address
    oneline
  end

  def save
    r = super
    
    @already_geocoded = false
    puts "saved address now Geocoded? #{@already_geocoded}"
    
    r
  end

  def address=(string)
    return unless string.presence && !postal_changed?

    r = Geocoder.search(string)
    puts "UPDATE_FROM_ADDRESS Geocoded? #{@already_geocoded}"
    @already_geocoded = true
    puts "UPDATE_from address now Geocoded? #{@already_geocoded}"

    if(r.length == 0) 
      puts "No results."
      self.errors[:address] = "No locations found."
      self.line1 = string
    elsif(r.length == 1)
      res = r[0]
      self.line1 = res.street_address
      self.line2 = nil
      self.city = res.city
      self.state = res.state_code
      self.postal = res.postal_code
      self.country = res.country_code
    else
      puts "TOo many."
      self.line1 = string
      self.errors[:address] = "Too many matches."
    end
    string
  end
  
  def as_json(options)
    hash = super(options)
    hash[:address] = oneline
    hash
  end

  def update_from_postal
    puts "UPDATE_FROM_POSTAL Geocoded? #{@already_geocoded}, '#{self.postal}'"
    return if @already_geocoded
    r = Geocoder.search(self.postal)
    if(r.length == 0)
      self.errors[:postal] = "Couldn't locate postal code"
    elsif(r.length == 1)
      res = r[0]
      self.city = res.city
      self.state = res.state_code
      self.country = res.country_code
    else
      self.errors[:postal] = "Too many matches"
    end
  end

  def update_attributes hash
    super

    self.postal= hash[:postal]
  end
  
  def admin_object_name
    [line1, city, postal].join(" ").strip rescue ""
  end

  def oneline
    "#{line1}, #{city}, #{state}"
  end

  def self.parse(string)
    a = Address.new
    a.address = string
    a.save
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
