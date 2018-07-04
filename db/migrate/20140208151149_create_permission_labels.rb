class CreatePermissionLabels < ActiveRecord::Migration[5.2]
  def change
    create_table :permission_labels do |t|
      t.string :name

      t.timestamps
    end
  end
end
