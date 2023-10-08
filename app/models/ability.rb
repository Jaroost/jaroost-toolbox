# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.nil?
      return
    end
    roles=user.keycloak_roles
    roles.each do |role|
      role.attributes.each do |action, subjects|
        subjects.each do |subject|
          begin
            can action.to_sym, subject.constantize
          rescue
            can action.to_sym, subject.to_sym
          end
        end
      end
    end
  end
end
