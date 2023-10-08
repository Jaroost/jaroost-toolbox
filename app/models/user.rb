class User < GroupScoped
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :timeoutable, :omniauthable, omniauth_providers: [:keycloak]
  has_many :roles, class_name: 'UserRole', inverse_of: :user

  #Retourne la liste des roles keycloak(représentation) de l'utilisateur
  def keycloak_roles
    current_user_role_names=self.roles.map{|r|r.role_name}
    if current_user_role_names.empty?
      []
    else
      Keycloak::Client.get_psp_roles.roles.select{|r|current_user_role_names.include?(r.name)}
    end
  end

  MANDATORY_FIELDS=[
    {name: "provider", description: "Le fournisseur d'authentification (keycloak)", type: "String"},
    {name: "uid", description: "l'id de l'utilisateur le fournisseur d'authentification", type: "String"},
    {name: "info.email", description: "l'email de l'utilisateur", type: "String"},
    {name: "info.full_name", description: "le nom complet de l'utilisateur (prénom + nom)", type: "String"},
    {name: "credentials.refresh_token", description: "Le token de rafraichissement de la connexion", type: "String"},
    {name: "credentials.token", description: "Le token de connexion", type: "String"},
    {name: "info.roles", description: "Les roles de l'utilisateur (un tableau de nom de rôle)", type: "Array"},
    {name: "info.group_identification_name", description: "L'identification du groupe de l'utilisateur", type: "String"},
    {name: "info.client_identification_name", description: "L'identification du client de l'utilisateur", type: "String"}
  ]
  def self.check_keycloak_fields(auth)
    missing_fields=[]
    MANDATORY_FIELDS.each do |field_description|
      case field_description.type
      when "String"
        if auth.send_multi_level(field_description.name).blank?
          missing_fields<<field_description
        end
      when "Array"
        if auth.send_multi_level(field_description.name).nil?
          missing_fields<<field_description
        end
      else
        missing_fields<<field_description
      end
    end
    unless missing_fields.empty?
      missing_fields_info=missing_fields.map{|field|"#{field.name}: #{field.description}"}.join("\n * ")
      raise "les données de connexion sont incomplètes! les informations suivante sont manquantes:\n * #{missing_fields_info}"
    end
  end

  #METTRE A JOUR check_keycloak_fields EN CAS DE MODIFICATION!!!
  def self.from_omniauth(auth)
    check_keycloak_fields(auth)
    User.group_unscoped do
      relation = where(provider: auth.provider, uid: auth.uid).joins(:group)
      ret=relation.first_or_create
      ret.email=auth.info.email
      ret.full_name=auth.info.full_name
      ret.refresh_token=auth.credentials.refresh_token
      ret.token=auth.credentials.token
      #ret.group = Group.unscoped.find_by(identification_name: auth.info.group_identification_name)
      #ret.client = Client.unscoped.find_by(identification_name: auth.info.client_identification_name)
      ret.set_roles_with_auth(auth)
      ret.save
      ret
    end
  end

  #Récupère les noms des roles associé à cet utilisateur dans le token de keycloak
  def set_roles_with_auth(auth)
    self.roles.delete_all
    if auth.info.roles
      auth.info.roles.each do |role_name|
        self.roles<<UserRole.new(role_name: role_name)
      end
    end
  end

end
