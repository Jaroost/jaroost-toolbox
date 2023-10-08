# frozen_string_literal: true

module ColumnExtension::Ownership
  extend ColumnExtension

  EXTENSION_NAME = :ownership
  COLUMNS = [
    { name: :ownership, type: :string, default_options: {null: false, index: true} }
  ]

  # For IDE autocomplete
  def ownership; end

  def add_ownership; end

  def remove_ownership; end

end