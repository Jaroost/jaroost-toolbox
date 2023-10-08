class Group < ApplicationRecord

  HIERARCHY_START = '~'
  HIERARCHY_SEPARATOR = '>'

  has_many :elements, class_name: 'GroupScoped', primary_key: :group_id, inverse_of: :group
  # has_many :users, class_name: 'GroupScoped', primary_key: :group_id, inverse_of: :group

  has_many :child_group, class_name: 'Group', foreign_key: :group_id, inverse_of: :parent_group
  belongs_to :parent_group, class_name: 'Group', foreign_key: :group_id, optional: true, inverse_of: :child_group

  before_save :set_hierarchy

  scope :name_a, ->{where(name: ['a'..'b'])}
  scope :in_hierarchy, ->(group) do
    if Current.default_scope_activated
      if group.nil?
        where('1=0')
      else
        where("#{table_name}.hierarchy LIKE ?", group.hierarchy + '%')
      end
    else
      all
    end
  end
  default_scope {in_hierarchy(Current.group_scope)}
  def set_hierarchy
    self.hierarchy = HIERARCHY_START + parents_path.join(HIERARCHY_SEPARATOR)
  end

  def all_children
    children = []
    self.direct_children.each do |child|
      children << child
      children << child.children
    end
    children
  end

  def is_root?
    self.parent_group.nil?
  end

  def parents_path
    if is_root?
      return [self.id]
    end
    parent_group.parents_path + [self.id]
  end
end
