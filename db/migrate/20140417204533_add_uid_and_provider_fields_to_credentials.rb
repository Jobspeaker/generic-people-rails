class AddUidAndProviderFieldsToCredentials < ActiveRecord::Migration
  def change
    add_column :credentials, :provider, :string
    add_column :credentials, :uid, :string
  end
end
