class Keycloak::Representation::Realm < Keycloak::Representation
  define_attribute(:is_registration_enabled, :registrationAllowed)
end