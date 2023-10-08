# frozen_string_literal: true

class GroupScoped < ApplicationRecord
  self.abstract_class = true

  belongs_to :group, class_name: 'Group', foreign_key: :group_id, inverse_of: :elements

  scope :in_hierarchy, ->(group){joins(:group)}
  default_scope {in_hierarchy(Current.group_scope)}

  def self.group_unscoped
    self.unscoped do
      Group.unscoped do
        yield
      end
    end
  end

end
