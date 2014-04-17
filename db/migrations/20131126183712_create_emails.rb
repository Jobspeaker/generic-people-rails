class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.references :label, index: true
      t.string :address

      t.timestamps
    end
  end
end
