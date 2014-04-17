class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
      t.references :person, index: true
      t.references :email, index: true
      t.string :password

      t.timestamps
    end
  end
end
