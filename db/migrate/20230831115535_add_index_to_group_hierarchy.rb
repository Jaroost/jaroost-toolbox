class AddIndexToGroupHierarchy < ActiveRecord::Migration[7.0]
  def change
    add_index :groups, :hierarchy
  end
end
