class CreateEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :emails do |t|
      t.references :label
      t.string :address
      t.boolean :confirmed, default: false

      t.timestamps
    end
  end
end
