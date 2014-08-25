# desc "Explaiinng what the task does"
# task :generic_people_rails do
#   # Task goes here
# end
require "csv"
require "net/http"
namespace :gpr do
  task :populate => [:environment] do
    alphabet = %w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
    all_credentials = []
    10.times do |i|
      response = Net::HTTP.get_response("api.randomuser.me", "/")
      h = JSON(response.body)['results'][0]['user']
      ah = h['location']
      nh = h['name']
      person = Person.create(fname: nh['first'].titleize, minitial: alphabet.sample + ".", lname: nh['last'].titleize, birthdate: DateTime.strptime(h['dob'], "%s"))
      puts " - gpr:populate - anonymous person #{person.name} at ID##{person.id}"
      address = Address.create(line1: ah["street"].titleize, city: ah["city"].titleize, state: ah["state"].titleize, country: "US", postal: ah["zip"])
      home_phone = Phone.create(number: h["phone"], label: Label.get("Home"))
      cell_phone = Phone.create(number: h["cell"], label: Label.get("Cell"))
      email = Email.create(address: h["email"], label: Label.get(["Work", "Home"].sample))
      person.addresses << address
      person.phones << home_phone
      person.phones << cell_phone
      person.emails << email
      member = Member.create(person_id: person.id)
      credential = Credential.create(email: email, member_id: member.id, password: h['password'])
      all_credentials << "#{h['email']} => #{h['password']}"
      has_media_class = ((Kernel.const_get("Media")).class == Class) rescue nil
      if has_media_class
        raw_photo = Media.create(basetype: "image", mimetype: "image/jpeg", caption: "profile pic",
                                 short_desc: "#{h['first']}'s Profile Picture", resource_uri: h['picture'],
                                 member_id: member.id)
      end
      has_profile_pic_class = ((Kernel.const_get("ProfilePhoto")).class == Class) rescue nil
      if has_profile_pic_class
        profile_pic = ProfilePhoto.create(media_id: raw_photo.id, member_id: member.id)
      end
    end
    puts "Created the following login credentials"
    puts all_credentials
  end

  task :seed => [:environment] do
    filename = "#{File.dirname(__FILE__)}/fakename-seed.csv"
    CSV.foreach(filename, headers: true) do |row|
      h = row.to_hash
      person = Person.create(fname: h['GivenName'], minitial: h['MiddleInitial'], lname: h['Surname'], birthdate: h['Birthday'])
      address = Address.create(line1: h['StreetAddress'], city: h['City'], state: h['State'], country: h['Country'], postal: h['ZipCode'])
      phone = Phone.create(number: h['TelephoneNumber'], label: Label.get(['Work', 'Home', 'Cell'].sample))
      email = Email.create(address: h['EmailAddress'], label: Label.get(['Work', 'Home'].sample))
      person.addresses << address
      person.phones << phone
      person.emails << email
      member = Member.create(person_id: person.id)
      credential = Credential.create(email: email, member_id: member.id, password: 'Idtmp2tv!')
    end
  end
end
