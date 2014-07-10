class AddPrefixSuffixToPeople < ActiveRecord::Migration
  def change
    add_column :people, :prefix, :string, limit: 10
    add_column :people, :suffix, :string, limit: 10
  end
end
