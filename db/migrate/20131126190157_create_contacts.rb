class CreateContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :contacts do |t|
      t.references :person, index: true
      t.references :label, index: true
      t.string :title
      t.timestamps
    end
  end
end
