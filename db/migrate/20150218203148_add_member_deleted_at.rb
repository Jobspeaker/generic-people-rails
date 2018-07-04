class AddMemberDeletedAt < ActiveRecord::Migration[5.2]
  def change
    
    if !Member.column_names.include?("deleted_at") 
      add_column :members, :deleted_at, :timestamp
    end
    
  end
end
