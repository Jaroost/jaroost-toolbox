
class AddGroupScopeToClients < ActiveRecord::Migration[7.0]
  def change
    change_table :clients do |t|
      t.group_scope
    end
  end
end
