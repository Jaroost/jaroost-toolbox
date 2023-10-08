# frozen_string_literal: true

module ColumnExtension::Group
  extend ColumnExtension

  EXTENSION_NAME = :group_scope
  COLUMNS = [
      { name: :group_id, type: :integer, default_options: {null: false, index: true} }
    ]

  # For IDE autocomplete
  def group_scope; end

  def add_group_scope; end

  def remove_group_scope; end
end
