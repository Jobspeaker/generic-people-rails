class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :identifier
      t.references :person, index: true

      t.timestamps
    end
  end
end
