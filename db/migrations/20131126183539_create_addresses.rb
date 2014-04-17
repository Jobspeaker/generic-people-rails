class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.references :label, index: true
      t.string :line1
      t.string :line2
      t.string :city
      t.string :state
      t.string :postal
      t.string :country

      t.timestamps
    end
  end
end
