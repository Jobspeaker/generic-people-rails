class CreatePhones < ActiveRecord::Migration[5.2]
  def change
    create_table :phones do |t|
      t.references :label
      t.string :number
      t.references :carrier
      t.boolean :confirmed, default: false

      t.timestamps
    end
  end
end
