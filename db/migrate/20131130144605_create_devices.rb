class CreateDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |t|
      t.string :identifier
      t.references :person, index: true

      t.timestamps
    end
  end
end
