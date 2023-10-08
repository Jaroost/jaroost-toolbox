class UserRole < ApplicationRecord
  belongs_to :user, class_name: 'User', inverse_of: :roles
end
