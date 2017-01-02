require 'zodiac'

class Person < ActiveRecord::Base
  has_one :member                       # that's not unreasonable.  has_two :members would be strange.

  has_and_belongs_to_many :addresses
  accepts_nested_attributes_for :addresses

  has_and_belongs_to_many :phones
  accepts_nested_attributes_for :phones

  has_and_belongs_to_many :emails
  accepts_nested_attributes_for :emails

  has_and_belongs_to_many :nicknames
  accepts_nested_attributes_for :nicknames

  has_many :devices, dependent: :destroy
  accepts_nested_attributes_for :devices

  def self.lookup(name)
    person   = self.find_by(self.name_components(name))
    person ||= self.includes(:nicknames).joins(:nicknames).find_by("nicknames.moniker" => name)
    if not person
      people = self.all.collect {|p| [p.id, [(p.fname[0] rescue ""), (p.minitial[0] rescue ""), (p.lname[0] rescue "")].join("").upcase] }
      people.each do |parry|
        return self.find(parry[0]) if parry[1] == name.upcase
      end
    end

    if not person
      addr = Email.find_by_address(name.downcase)
      person = addr.person if addr
    end

    person
  end

  def as_json(options={})
    for_member = options.delete(:for_member)
    hash = super(options)
    hash[:name] = name
    hash
  end

  def self.find_or_create_by(hash)
    options = hash.clone
    if options.has_key?(:name)
      options = options.merge(self.name_components(options[:name]))
      options.delete(:name)
    end
    super(options)
  end

  def self.find_by_nickname(moniker)
    person = self.includes(:nicknames).joins(:nicknames).find_by("nicknames.moniker" => moniker)
  end

  def self.find_by_email(addr)
    e = Email.find_by_address(addr)
    e.person if e
  end

  def self.find_by_phone_number(number)
    p = Phone.find_by_number(number)
    p.person if p
  end

  def self.find_by_address(string)
    a = Address.find_by_address(string)
    a.person if a
  end

  def self.authenticate(username, password)
    me = self.find_by_email(username)
    return me if me and me.credentials and password == me.credentials.password
  end
  
  def self.is_name_prefix?(text)
    possibles = %w(mr mrs ms miss dr professor prof)
    result = possibles.include?(text.gsub(/[.]*/, "").downcase) if text.present?
  end

  def self.is_name_suffix?(text)
    possibles = %w(esq phd jr iii ii)
    result = possibles.include?(text.gsub(/[.]*/, "").downcase) if text.present?
  end

  def self.name_components(name)
    res = {}
    component = ""
    components = name.gsub(/,/, " ").gsub(/  /, " ").split(" ") rescue [name]
    num_parts = components.length
    component = components.shift

    # What kind of thing is this?
    if is_name_prefix?(component)
      res[:prefix] = component
      res[:fname] = components.shift
    else
      res[:fname] = component
    end

    # Next up, middle initial or last name.
    # If only one word remains, that's the last name
    if components.length == 1
      res[:lname] = components.shift
    elsif components.length > 0
      # At least 2 words remain. We might have middle names, prefixes, suffixes, etc.
      components.reverse!
      component = components.shift
      if is_name_suffix?(component)
        res[:suffix] = component
        res[:lname] = components.shift
      else
        res[:lname] = component
      end
      res[:minitial] = components.shift
    end

    res[:minitial] = res[:minitial].gsub(/[.]/, "") if res[:minitial].present?
    res
  end

  def add_nickname(moniker)
    if self != self.class.find_by_nickname(moniker)
      nick = Nickname.create(moniker: moniker)
      nicknames << nick
    end
  end

  def add_phone(number, label="Home")
    if self != self.class.find_by_phone_number(number)
      p = Phone.create(number: number, label: Label.get(label))
      phones << p
    end
    p = Phone.find_by_number(number)
  end

  def add_email(address, label="Home")
    if self != self.class.find_by_email(address)
      e = Email.create(address: address, label: Label.get(label))
      emails << e
    end
    e = Email.find_by(address: address)
  end

  def add_address(address_line, label="Home")
    if self != self.class.find_by_address(address_line)
      a = Address.parse(address_line); a.save
      a.label = Label.get(label)
      a.save
      addresses << a
    end
    a = Address.find_by_address(address_line)
  end

  def add_moniker(moniker)
    add_nickname(moniker)
  end

  def monikers
    nicknames.pluck(:moniker)
  end

  def initials
    res = ""
    res += fname[0] if not fname.blank?
    res += minitial[0] if not minitial.blank?
    res += lname[0] if not lname.blank?
    res.upcase
  end

  def nickname
    monikers.first || initials
  end

  def register_device(identifier)
    dev = devices.find_or_create_by_identifier(identifier)
    dev.save
  end

  def name
    components = []

    if prefix.present?
      if not prefix.include?(".")
        components << "#{prefix}."
      else
        components << prefix
      end
    end

    components << fname if fname.present?

    if minitial.present?
      if minitial.length < 2
        components << "#{minitial}."
      else
        components << minitial
      end
    end

    components << lname if lname.present?
    components << ", #{suffix}" if suffix.present?
    components.join(" ").strip.gsub(/ ,/, ",")
  end

  def name=(incoming_name)
    components = self.class.name_components(incoming_name)
    self.prefix = components[:prefix]
    self.fname = components[:fname]
    self.minitial = components[:minitial]
    self.lname = components[:lname]
    self.suffix = components[:suffix]
  end

  def age
    ((Date.today - self.birthdate).to_i / 365) if self.birthdate.present?
  end

  def age=(new_age)
    self.birthdate = (Date.today - (rand(Date.today.month - 1))) - new_age.years
    self.birthdate
  end

  def zodiac_sign
    self.birthdate.zodiac_sign if self.birthdate.present?
  end
  
  ## this is so not a cool thing to do. 
=begin
  def email=(eaddr)
    if eaddr.is_a?(Email)
      emails << eaddr unless emails.include?(eaddr)
      return
    end

    e = emails.first rescue nil
    e ||= Email.create(label: Label.get("Work"))
    e.address = eaddr
    emails << e unless emails.include?(e)
    e.save
  end
=end
  def email_address=(eaddr)
    e = emails.first rescue nil
    e ||= Email.create(:label => Label.get("Work"))
    emails << e unless emails.include?(e)
    e.address = eaddr.downcase.strip
    e.save
  end

  def email
    e = emails.find_by(label: Label.get("Work"))
    e ||= emails.first
    e
  end

  def email_address
    e = emails.find_by(label: Label.get("Work"))
    e ||= emails.first
    e.address rescue nil
  end

  def phone=(number)
    if number.is_a?(Phone)
      phones << number unless phones.include?(number)
      return
    end

    if not number.blank?
      p = phones.first rescue nil
      p ||= Phone.create(:label => Label.get("Work"))
      phones << p unless phones.include?(p)
      p.number = number
      p.save
    end
  end

  def phone
    p = self.phones.find_by(label: Label.get("Work"))
    p ||= self.phones.first
    p
  end

  def phone_number=(number)
    if not number.blank?
      p = phones.first rescue nil
      p ||= Phone.create(:label => Label.get("Work"))
      phones << p unless phones.include?(p)
      p.number = number
      p.save
    end
  end

  def phone_number
    p = self.phones.find_by(label: Label.get("Work"))
    p ||= self.phones.first
    p.number if p
  end

  def set_phone_number(label, number)
    p = self.phones.find_or_create_by_label(Label.get(label))
    if not number.blank?
      phones << p unless phones.include?(p)
      p.number = number
      p.save
    else
      p.destroy if p
    end
  end

  def cell_phone_number=(number)
    self.set_phone_number("Cell", number)
  end

  def work_phone_number=(number)
    self.set_phone_number("Work", number)
  end

  def home_phone_number=(number)
    self.set_phone_number("Home", number)
  end

  def cell_phone_number
    self.phones.find_by(label: Label.get("Cell")).number rescue nil
  end

  def work_phone_number
    self.phones.find_by(label: Label.get("Work")).number rescue nil
  end

  def home_phone_number
    self.phones.find_by(label: Label.get("Home")).number rescue nil
  end

  def address=(new_address)
    if new_address.is_a?(Address)
      self.addresses << new_address unless self.addresses.include?(new_address)
    elsif new_address.class == Integer || new_address.class == Fixnum || new_address.class == Bignum
      a = Address.find(new_address)
      self.addresses << a unless self.addresses.include?(a)
    else
      parsed = Address.parse(new_address)
      current = addresses.where(line1: parsed.line1).first
      current ||= Address.new
      parsed.attributes.each {|key, val| current.send((key + "=").to_sym, val) unless val == nil }
      current.save
      self.addresses << current unless self.addresses.include?(current)
    end
    self.save
  end

  def address
    a = self.addresses.find_by(label: Label.get("Work"))
    a ||= self.addresses.first
  end

  def city=(new_city)
    a = addresses.first rescue nil
    a ||= addresses.find_or_create_by(city: new_city)
    a.city = new_city
    self.addresses << a unless self.addresses.include?(a)
    a.save and self.save
  end

  def line1=(new_line1)
    self.address = new_line1
  end

  def line2=(new_line2)
    a = addresses.first rescue nil
    a ||= addresses.find_or_create_by(line2: new_line2)
    a.line2 = new_line2
    self.addresses << a unless self.addresses.include?(a)
    a.save and self.save
  end

  def state=(new_state)
    a = addresses.first rescue nil
    a ||= addresses.find_or_create_by(state: new_state)
    a.state = new_state
    self.addresses << a unless self.addresses.include?(a)
    a.save and self.save
  end

  def postal=(new_postal)
    a = addresses.first rescue nil
    a ||= addresses.find_or_create_by(postal: new_postal)
    a.postal = new_postal
    self.addresses << a unless self.addresses.include?(a)
    a.save and self.save
  end
  
  def self.make_parseable_birthdate(date_string)
    b = date_string
    m = 0; d = 0; y = 0
    return if b.blank?
    if b.length == 8
      # 12/11/59
      m = b[0..1].to_i rescue nil
      d = b[3..4].to_i rescue nil
      y = b[6..7].to_i rescue nil
      y = y + 1900
    elsif b.length == 10
      # 12/11/1959
      m = b[0..1].to_i rescue nil
      d = b[3..4].to_i rescue nil
      y = b[6..9].to_i rescue nil
    end
    
    maybe = Date.new(y, m, d).to_s rescue nil
    maybe ||= Date.parse(b) rescue nil
    maybe
  end

  def update_attributes(attrs)
    args = attrs
    if args[:birthdate].class == String
      args[:birthdate] = Person.make_parseable_birthdate(args[:birthdate])
    end
    super(args)
  end
end
