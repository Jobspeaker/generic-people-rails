class CreateCarriers < ActiveRecord::Migration
  def change
    create_table :carriers do |t|
      t.string :name
      t.string :sms_gateway

      t.timestamps
    end
  end
end
