class Keycloak::Representation::RolesContainer < Keycloak::Representation
  attr_accessor :roles
  def set_values_with_keycloak(keycloak_info)
    self.roles=[]
    keycloak_info.each do |role|
      self.roles<<Keycloak::Representation::Role.new(keycloak_info:  role)
    end
  end
end