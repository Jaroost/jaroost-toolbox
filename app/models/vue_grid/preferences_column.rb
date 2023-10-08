class VueGrid::PreferencesColumn < ApplicationRecord
  self.table_name = 'vue_grid_preferences_columns'

  DIRECTION_HASH = {'asc' => true, 'desc' => false}

  def self.from_preference(user:, grid_id:, preference:, index:)
    preference = preference.deep_symbolize_keys
    new_record = VueGrid::PreferencesColumn.create(
      user_id: user.id,
      grid_id: grid_id,
      col_id: preference[:name],
      index: index,
      order_priority: preference[:columnFilter][:orderPriority],
      direction: VueGrid::PreferencesColumn::DIRECTION_HASH[preference[:columnFilter][:sortDirection]],
      is_visible: preference[:isVisible],
      pin_location: preference[:pinLocation]||"not_pinned",
      width: preference[:width],
      filter: preference[:columnFilter].to_json
    )
    new_record
  end

end
