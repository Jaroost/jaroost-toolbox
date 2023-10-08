class CreateUserRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :user_roles do |t|
      t.string :role_name
      t.integer :user_id

      t.timestamps
    end
  end
end
