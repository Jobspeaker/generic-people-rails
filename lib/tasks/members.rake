namespace :gpr do
  namespace :members do
    task :pick => :environment do
      adapter = Person.connection.instance_variable_get(:@config)[:adapter]
      db_rand = "RAND()" if adapter == "mysql2"
      db_rand = "RANDOM()" if adapter == "postgresql"
      db_rand ||= "ID DESC"
      c = Credential.order(db_rand).first
      puts "Username: #{c.email.address}; Password: #{c.password}"
    end

    task :show => :environment do
      member = Member.lookup(ENV["name"])
      puts member.name
      puts member.credentials.first.email.address
      puts member.credentials.first.password
    end
  end
end
