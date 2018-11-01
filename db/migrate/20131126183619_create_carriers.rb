class CreateCarriers < ActiveRecord::Migration[5.2]
  def change
    create_table :carriers do |t|
      t.string :name
      t.string :sms_gateway

      t.timestamps
    end
  end
end
