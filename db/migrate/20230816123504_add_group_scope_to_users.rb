class AddGroupScopeToUsers < ActiveRecord::Migration[7.0]
  def change
    add_group_scope :users, group_id_options: {null:true}
  end
end
