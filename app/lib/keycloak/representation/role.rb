class Keycloak::Representation::Role < Keycloak::Representation
  define_attribute(:name, :name)
  define_attribute(:description, :description)
  define_attribute(:attributes, :attributes)
end