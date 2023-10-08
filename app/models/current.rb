# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  # Pour le scope grouped
  attribute :user
  attribute :group_scope

  # Pour l'authentication "sans" default scope
  attribute :default_scope_activated

  def scope_request(request_user)
    self.user = request_user
    self.group_scope = request_user&.group
    self.default_scope_activated = true
  end

  def default_scope_activated?
    self.default_scope_activated
  end

  #Pour impersonate
  attribute :true_user
end