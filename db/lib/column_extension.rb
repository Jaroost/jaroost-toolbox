# frozen_string_literal: true

module ColumnExtension

  EXTENSION_NAME = nil
  COLUMNS = nil

  def retrieve_options(col, **options)
    declared_options = options["#{col[:name]}_options".to_sym]
    col[:default_options].merge(declared_options || {})
  end

  def migration_extension
    mod = self
    @migration_extension ||= Module.new do
      define_method("add_#{mod::EXTENSION_NAME}".to_sym) do |table_name, **options|
        mod::COLUMNS.each do |col|
          opts = mod.retrieve_options col, **options
          add_column(table_name, col[:name].to_sym, col[:type].to_sym, **opts)
        end
      end

      define_method("remove_#{mod::EXTENSION_NAME}".to_sym) do |table_name, **options|
        mod::COLUMNS.each do |col|
          opts = mod.retrieve_options col, **options
          remove_column(table_name, col[:name].to_sym, col[:type].to_sym, **opts)
        end
      end
    end
  end

  def table_extension
    mod = self
    @table_extension ||= Module.new do
      define_method("#{mod::EXTENSION_NAME}".to_sym) do |**options|
        mod::COLUMNS.each do |col|
          opts = mod.retrieve_options col, **options
          @base.add_column(name, col[:name].to_sym, col[:type].to_sym, **opts)
        end
      end
    end
  end

  def table_definition_extension
    mod = self
    @table_definition_extension ||= Module.new do
      define_method("#{mod::EXTENSION_NAME}".to_sym) do |**options|
        mod::COLUMNS.each do |col|
          opts = mod.retrieve_options col, **options
          column(col[:name].to_sym, col[:type].to_sym, **opts)
        end
      end
    end
  end
end


