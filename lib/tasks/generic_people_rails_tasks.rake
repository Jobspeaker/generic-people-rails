# desc "Explaining what the task does"
# task :generic_people_rails do
#   # Task goes here
# end
require "csv"

namespace :gpr do
  task :seed => [:environment] do
    filename = "#{File.dirname(__FILE__)}/fakename-seed.csv"
    CSV.foreach(filename, headers: true) do |row|
      h = row.to_hash
      person = Person.create(fname: h["GivenName"], minitial: h["MiddleInitial"], lname: h["Surname"], birthdate: h["Birthday"])
      address = Address.create(line1: h["StreetAddress"], city: h["City"], state: h["State"], country: h["Country"], postal: h["ZipCode"])
      phone = Phone.create(number: h["TelephoneNumber"], label: Label.get(["Work", "Home", "Cell"].sample))
      email = Email.create(address: h["EmailAddress"], label: Label.get(["Work", "Home"].sample))
      person.addresses << address
      person.phones << phone
      person.emails << email
      member = Member.create(person_id: person.id)
      credential = Credential.create(email: email, member_id: member.id, password: "Idtmp2tv!")
    end
  end
end
