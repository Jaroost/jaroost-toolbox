class Keycloak::Representation
  include ActiveModel::Serializers::JSON
  include ActiveModel::Validations
  attr_accessor :id, :keycloak_info, :is_loaded
  def initialize(keycloak_info:{})
    @is_loaded=!keycloak_info.empty?
    unless keycloak_info.empty?
      set_values_with_keycloak(keycloak_info)
    end
  end

  def set_values_with_keycloak(keycloak_info)
    self.keycloak_info=keycloak_info
    self.id=keycloak_info['id'] unless keycloak_info.is_a? Array
    keycloak_info.keys.each do |key|
      if self.respond_to?("keycloak_#{key}=")
        self.send("keycloak_#{key}=", keycloak_info[key])
      elsif self.respond_to?("#{key}=")
        self.send("#{key}=", keycloak_info[key])
      end
    end
  end

  def attributes
    instance_values
  end
  def as_json(option={})
    super
      .except('is_loaded', 'keycloak_info')
      .transform_keys{|key| key.starts_with?('keycloak_') ? key.sub('keycloak_', ''): key}

  end

  def self.define_attribute(ruby_name, api_name)
    module_eval <<-STR, __FILE__, __LINE__ + 1
      attr_accessor :#{api_name}
    STR
    if ruby_name && ruby_name != api_name
      module_eval <<-STR, __FILE__, __LINE__ + 1
        alias_attribute  :#{ruby_name}, :#{api_name}
      STR
    end
  end

end