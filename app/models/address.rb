class Address < ActiveRecord::Base
  belongs_to :label
  has_and_belongs_to_many :people

  def admin_object_name
    [line1, city, postal].join(" ").strip rescue ""
  end

  def oneline
    "#{line1}, #{city}, #{state}"
  end

  def self.parse(string)
    a = Address.new
    components = string.split(",").collect(&:strip)
    a.line1 = components.shift
#    a.line2 = components.shift if components[0].split(" ").length > 1
    l = components.length - 1
    if l > 0
      if components.last =~ /[0-9]+$/
        a.postal = components.last
        components.pop
      end
    end
    a.city = components.shift rescue nil
    a.state = components.shift rescue nil
    a.country = components.shift rescue "USA"
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
