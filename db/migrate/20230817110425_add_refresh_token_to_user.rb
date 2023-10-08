class AddRefreshTokenToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :refresh_token, :text
    add_column :users, :token, :text
    add_column :users, :token_expires_at, :datetime
  end
end
