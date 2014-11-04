require 'bcrypt'
class AddSaltedPassword < ActiveRecord::Migration
  def change
    add_column :credentials, :salt, :string

    #create salt for existing passwords
    Credential.all.each do |cred|
      pw = BCrypt::Password.create(cred.attributes["password"])
      cred.update(salt: pw, password: nil)
    end
    
  end
end
