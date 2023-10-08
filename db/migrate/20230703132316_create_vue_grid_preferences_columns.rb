class CreateVueGridPreferencesColumns < ActiveRecord::Migration[7.0]
  def change
    create_table :vue_grid_preferences_columns do |t|
      t.integer :index
      t.string :grid_id, index: true
      t.bigint :user_id, index: true
      t.string :col_id
      t.integer :order_priority
      t.boolean :direction
      t.boolean :is_visible
      t.integer :width
      t.string :pin_location
      t.text :filter

      t.timestamps
    end
  end
end
