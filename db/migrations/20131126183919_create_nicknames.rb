class CreateNicknames < ActiveRecord::Migration
  def change
    create_table :nicknames do |t|
      t.string :moniker

      t.timestamps
    end
  end
end
