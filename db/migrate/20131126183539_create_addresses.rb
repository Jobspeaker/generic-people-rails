class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.references :label
      t.string :line1, :line2, :city, :state, :postal, :country
      t.float :lat, :lon
      t.boolean :confirmed, default: false

      t.timestamps
    end
  end
end
