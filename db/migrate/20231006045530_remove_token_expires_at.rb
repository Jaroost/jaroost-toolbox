class RemoveTokenExpiresAt < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :token_expires_at
  end
end
