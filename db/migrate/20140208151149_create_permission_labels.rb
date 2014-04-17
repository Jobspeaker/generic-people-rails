class CreatePermissionLabels < ActiveRecord::Migration
  def change
    create_table :permission_labels do |t|
      t.string :name

      t.timestamps
    end
  end
end
