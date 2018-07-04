class CreateLastLogins < ActiveRecord::Migration[5.2]
  def change
    create_table :last_logins do |t|
      t.references :member, index: true
      t.datetime :moment

      t.timestamps
    end
  end
end
