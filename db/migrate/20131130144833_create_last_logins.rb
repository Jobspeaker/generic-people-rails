class CreateLastLogins < ActiveRecord::Migration
  def change
    create_table :last_logins do |t|
      t.references :person, index: true
      t.datetime :moment

      t.timestamps
    end
  end
end
