class CreateGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :groups do |t|
      t.string :name
      t.text :hierarchy
      t.group_scope group_id_options: {null: true}
      t.timestamps
    end
  end
end
