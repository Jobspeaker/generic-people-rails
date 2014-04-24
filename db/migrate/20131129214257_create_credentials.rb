class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
      t.references :member, index: true
      t.references :email, index: true
      t.references :person, index: true

      t.string :password
      t.string :provider, index: true
      t.string :uid, index: true

      t.timestamps
    end
  end
end
