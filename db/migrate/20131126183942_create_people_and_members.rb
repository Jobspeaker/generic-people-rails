class CreatePeopleAndMembers < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :fname
      t.string :lname
      t.string :minitial
      t.date :birthdate

      t.timestamps
    end

    create_table :members do |t|
      t.references :person
      t.string     :status
      t.timestamps
    end

    create_table :nicknames_people, id: false do |t|
      t.references :nickname
      t.references :person
    end

    create_table :addresses_people, id: false do |t|
      t.references :address
      t.references :person
    end

    create_table :emails_people, id: false do |t|
      t.references :email
      t.references :person
    end

    create_table :people_phones, id: false do |t|
      t.references :person
      t.references :phone
    end

  end
end
