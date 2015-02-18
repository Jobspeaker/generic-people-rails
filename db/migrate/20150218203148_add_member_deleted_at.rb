class AddMemberDeletedAt < ActiveRecord::Migration
  def change
    
    add_column :members, :deleted_at, :timestamp
    
  end
end
