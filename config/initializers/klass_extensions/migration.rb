# frozen_string_literal: true

class ActiveRecord::Migration
  include(::ColumnExtension::Ownership.migration_extension)
  include(::ColumnExtension::Group.migration_extension)
end

class ActiveRecord::ConnectionAdapters::Table
  include(::ColumnExtension::Ownership.table_extension)
  include(::ColumnExtension::Group.table_extension)
end

class ActiveRecord::ConnectionAdapters::TableDefinition
  include(::ColumnExtension::Ownership.table_definition_extension)
  include(::ColumnExtension::Group.table_definition_extension)
end
