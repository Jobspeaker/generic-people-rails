class AddPersonIdColumnToCredentials < ActiveRecord::Migration
  def change
    add_column :credentials, :person_id, :integer
    add_index :credentials, :person_id
  end
end
