class Person < ActiveRecord::Base
  has_and_belongs_to_many :addresses
  has_and_belongs_to_many :phones
  has_and_belongs_to_many :emails
  has_and_belongs_to_many :nicknames

  has_many :devices
  has_many :last_logins
  has_many :credential_records, :class_name => "Credential", :foreign_key => :person_id

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

  def self.find_by_nickname(moniker)
    person = self.includes(:nicknames).joins(:nicknames).find_by("nicknames.moniker" => moniker)
  end

  def self.find_by_email(addr)
    e = Email.find_by_address(addr)
    e.person if e
  end

  def self.authenticate(username, password)
    me = self.find_by_email(username)
    return me if me and me.credentials and password == me.credentials.password
  end
  
  def self.name_components(name)
    res = {}
    components = name.split(" ")
    res[:fname] = components[0]
    if components.length == 3
      res[:minitial] = components[1]
      res[:lname] = components[2]
    else
      res[:lname] = components[1]
    end
    res
  end

  def add_nickname(moniker)
    if self != self.class.find_by_nickname(moniker)
      nick = Nickname.create(moniker: moniker)
      nicknames << nick
    end
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

  def credentials
    self.credential_records[0] rescue nil
  end

  def update_last_login
    last_logins << LastLogin.create(:person => self, :moment => DateTime.now)
  end

  def register_device(identifier)
    dev = devices.find_or_create_by_identifier(identifier)
    dev.save
  end

  def name
    [fname, minitial, lname].join(" ").strip
  end

  def name=(incoming_name)
    components = self.class.name_components(incoming_name)
    self.fname = components[:fname]
    self.lname = components[:lname]
    self.minitial = components[:minitial]
  end

  def email=(eaddr)
    e = emails.first rescue nil
    e ||= Email.create(:label => Label.get("Work"))
    emails << e unless emails.include?(e)
    e.address = eaddr.downcase.strip
    e.save
  end

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
    if new_address.class == Address
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
    args.delete(:provides)
    args.delete(:wage)
    if args[:birthdate].class == String
      args[:birthdate] = Person.make_parseable_birthdate(args[:birthdate])
    end
    super(args)
  end
end