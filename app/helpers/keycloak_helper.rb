module KeycloakHelper
  def keycloak_sign_in_path
    omniauth_authorize_path(:user, :keycloak)
  end

  def keycloak_registration_path
    "#{openid_path}/registrations?client_id=#{ENV['PSP_KEYCLOAK_CLIENT_ID']}&response_type=code&scope=#{ENV['PSP_KEYCLOAK_SCOPE']}&redirect_uri=#{current_host_path('after_register')}"
  end

  def keycloak_account_path
    "#{realm_path}/account?referrer=#{ENV['PSP_KEYCLOAK_CLIENT_ID']}#/personal-info"
  end

  def keycloak_logout_path
    "#{openid_path}/logout?client_id=#{ENV['PSP_KEYCLOAK_CLIENT_ID']}&post_logout_redirect_uri=#{current_host_path('after_logout')}"
  end

  def keycloak_admin_console_path
    "https://#{ENV['APP_PUBLIC_HOST']}#{ENV['PSP_KEYCLOAK_BASE_URL']}/admin/master/console/#/#{ENV['PSP_KEYCLOAK_REALM']}"
  end

  private

  def current_host_path(resource='')
    url_for("#{root_url}#{resource}")
  end

  def realm_path
    "#{ENV['PSP_KEYCLOAK_SITE']}#{ENV['PSP_KEYCLOAK_BASE_URL']}/realms/#{ENV['PSP_KEYCLOAK_REALM']}"
  end

  def openid_path
    "#{realm_path}/protocol/openid-connect"
  end
end