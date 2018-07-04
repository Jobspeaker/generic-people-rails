class CreatePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :permissions do |t|
      t.references :credential, index: true
      t.references :permission_label, index: true

      t.timestamps
    end
  end
end
