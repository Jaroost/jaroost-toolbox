class Keycloak::Client
  @realm_representation=Keycloak::Representation::Realm.new
  @psp_representation=Keycloak::Representation::Client.new
  @psp_roles_container=Keycloak::Representation::RolesContainer.new

  #Permet de réinitialiser les représentations de toutes les représentation enregistrées dans la mémoire du serveur
  def self.reset_representations
    @realm_representation=Keycloak::Representation::Realm.new
    @psp_representation=Keycloak::Representation::Client.new
    @psp_roles_container=Keycloak::Representation::RolesContainer.new
  end

  #Permet de mettre à jour le token de l'utilisateur si ne fonctionne pas, renvoie une erreur
  def self.refresh_token(user)
    if user
      response=Faraday.new(url: BASE_URL).post(TOKEN_URL) do |request|
        request.headers['Content-Type']='application/x-www-form-urlencoded'
        request.body = URI.encode_www_form({
                                             client_id: ENV['PSP_KEYCLOAK_CLIENT_ID'],
                                             grant_type: 'refresh_token',
                                             refresh_token: user.refresh_token,
                                             client_secret: ENV['PSP_KEYCLOAK_CLIENT_SECRET']
                                           })
      end
      if response.success?
        json_response=JSON.parse(response.body)
        user.token=json_response.access_token
        user.refresh_token=json_response.refresh_token
        user.save
      else
        user.token=nil
        user.refresh_token=nil
        raise Keycloak::Error::RefreshToken.new
      end
    end
  end

  #Permet de récupérer les sessions d'un utilisateur
  def self.get_user_sessions(user)
    token=get_admin_token
    response=Faraday.new(url: BASE_URL).get("#{ADMIN_URL}/users/#{user.uid}/sessions") do |request|
      request.headers["Authorization"] = "Bearer #{token}"
    end
    if response.success?
      response.body
    end
  end

  #Permet de récupérer la représentation du royaume psp
  def self.get_realm_representation
    unless @realm_representation.is_loaded
      begin
        token=get_admin_token
        response=Faraday.new(url: BASE_URL).get("#{ADMIN_URL}") do |request|
          request.headers["Authorization"] = "Bearer #{token}"
        end
        if response.success?
          @realm_representation=Keycloak::Representation::Realm.new(keycloak_info:JSON.parse(response.body))
        end
      rescue Exception => e
        Rails.logger.fatal "Erreur lors du téléchargement de la représentation du realm: \n#{e}"
      end
    end
    @realm_representation
  end

  #Permet de récupérer la représentation du client psp de keycloak
  def self.get_psp_client
    unless @psp_representation.is_loaded
      begin
        psp_client=self.get_realm_clients.find{|client| client['clientId']==ENV['PSP_KEYCLOAK_CLIENT_ID']}
        @psp_representation=Keycloak::Representation::Client.new(keycloak_info: psp_client)
      rescue Exception => e
        Rails.logger.fatal "Erreur lors du téléchargement de la représentation du client: \n#{e}"
      end
    end
    @psp_representation
  end

  #Permet de récupérer les roles de l'application psp sur keycloak
  def self.get_psp_roles
    unless @psp_roles_container.is_loaded
      if get_psp_client.is_loaded
        token=get_admin_token
        response=Faraday.new(url: BASE_URL).get("#{ADMIN_URL}/clients/#{get_psp_client.id}/roles?briefRepresentation=false") do |request|
          request.headers["Authorization"] = "Bearer #{token}"
        end
        roles=JSON.parse(response.body)
        @psp_roles_container=Keycloak::Representation::RolesContainer.new(keycloak_info: roles)
      end
    end
    @psp_roles_container
  end

  #Permet d'impersonate un utilisateur keycloak
  def self.impersonate_user(keycloak_id)
    token=get_admin_token
    response=Faraday.new(url: BASE_URL).post("#{ADMIN_URL}/users/#{keycloak_id}/impersonation") do |request|
      request.headers["Authorization"] = "Bearer #{token}"
    end
    unless response.success?
      raise "Error while impersonating user! #{response.body}"
    end
    response
  end

  #Permet de déconnecter toutes les sessions de l'utilisateur
  def self.logout_user(keycloak_id)
    token=get_admin_token
    response=Faraday.new(url: BASE_URL).post("#{ADMIN_URL}/users/#{keycloak_id}/logout") do |request|
      request.headers["Authorization"] = "Bearer #{token}"
    end
    unless response.success?
      raise "Error in logout user! #{response.body}"
    end
  end

  #Permet de récupérer toutes les représenation de tous les utilisateurs de keycloak
  def self.get_all_users
    token=get_admin_token
    response=Faraday.new(url: BASE_URL).get("#{ADMIN_URL}/users?max=10000") do |request|
      request.headers["Authorization"] = "Bearer #{token}"
    end
    if response.success?
      users=JSON.parse(response.body)
      representations=[]
      users.each do |user|
        representations<<Keycloak::Representation::User.new(keycloak_info: user)
      end
      representations
    else
      raise "Error while getting users #{response.body}"
    end

  end

  #Permet de récupérer la représentation de l'utilisateur sur Keycloak
  def self.get_user_representation(psp_user)
    token=get_admin_token
    response=Faraday.new(url: BASE_URL).get("#{ADMIN_URL}/users/#{psp_user.uid}?userProfileMetadata=true") do |request|
      request.headers["Authorization"] = "Bearer #{token}"
    end
    if response.success?
      Keycloak::Representation::User.new(keycloak_info: JSON.parse(response.body))
    else
      raise "Error while getting representation! #{response.body}"
    end
  end

  #Permet de mettre à jour la représentation d'un utilisateur sur keycloak
  def self.set_user_representation(representation)
    token=get_admin_token
    response=Faraday.new(url: BASE_URL).put("#{ADMIN_URL}/users/#{representation.id}") do |request|
      request.headers["Authorization"] = "Bearer #{token}"
      request.headers["Content-Type"] = "application/json"
      request.body=representation.to_json
    end
    unless response.success?
      raise "Error while setting representation! #{response.body}"
    end
  end

  #Permet de mettre à jour les attributes d'un utilisateur (ne permet pas de supprimer des attributs)
  def self.update_user_attributes(psp_user, attributes:{})
    user_representation=get_user_representation(psp_user)
    user_representation.keycloak_attributes.merge!(attributes)
    set_user_representation(user_representation)
  end

  def self.update_user_required_actions(psp_user, required_actions: [])
    user_representation=get_user_representation(psp_user)
    user_representation.required_actions.concat(required_actions)
    set_user_representation(user_representation)
  end

  #Envoie un mail à l'utilisateur avec l'id keycloak_id d'executer les required actions
  def self.execute_actions_email(keycloak_id)
    token=get_admin_token
    response=Faraday.new(url: BASE_URL).put("#{ADMIN_URL}/users/#{keycloak_id}/execute-actions-email") do |request|
      request.headers["Authorization"] = "Bearer #{token}"
      request.headers["Content-Type"] = "application/json"
    end
    if response.success?
      response.body
    else
      Rails.logger.fatal "Erreur lors de la méthode execute_actions_email #{response.body}!"
      raise "Erreur lors de la méthode execute_actions_email #{response.body}!"
    end
  end

  def self.create_user(user_representation)
    token=get_admin_token
    response=Faraday.new(url: BASE_URL).post("#{ADMIN_URL}/users") do |request|
      request.headers["Authorization"] = "Bearer #{token}"
      request.headers["Content-Type"]="application/json"
      request.body=user_representation.to_json
    end
    unless response.success?
      raise "Error while creating user! #{response.body}"
    end
    response.body
  end

  private

  def self.get_admin_token
    token_response=Faraday.new(url: BASE_URL).post(ADMIN_TOKEN_URL, {grant_type: :password, client_id: 'admin-cli', password: ENV['KEYCLOAK_ADMIN_PASSWORD'], username: ENV['KEYCLOAK_ADMIN_USER']})
    if token_response.success?
      JSON.parse(token_response.body).symbolize_keys![:access_token]
    else
      raise "Error while getting admin token!"
    end
  end

  def self.get_realm_clients
    token=get_admin_token
    response=Faraday.new(url: BASE_URL).get("#{ADMIN_URL}/clients") do |request|
      request.headers["Authorization"] = "Bearer #{token}"
    end
    if response.success?
      JSON.parse(response.body)
    else
      Rails.logger.fatal "Erreur lors du téléchargement des clients #{response.body}!"
      raise "Erreur lors du téléchargement des clients #{response.body}!"
    end
  end

  #Pour l'API de connexion avec le user current
  BASE_URL=ENV['PSP_KEYCLOAK_SITE']
  TOKEN_URL="#{ENV['PSP_KEYCLOAK_BASE_URL']}/realms/#{ENV['PSP_KEYCLOAK_REALM']}/protocol/openid-connect/token"

  #Pour l'API de keycloak
  ADMIN_TOKEN_URL="#{ENV['PSP_KEYCLOAK_BASE_URL']}/realms/master/protocol/openid-connect/token"
  ADMIN_URL="#{ENV['PSP_KEYCLOAK_BASE_URL']}/admin/realms/#{ENV['PSP_KEYCLOAK_REALM']}"

end