class Keycloak::Representation::User < Keycloak::Representation

  KEYCLOAK_REQUIRED_ACTIONS_ONE_TIME_PASSWORD='CONFIGURE_TOTP'
  KEYCLOAK_REQUIRED_ACTIONS_UPDATE_PASSWORD='UPDATE_PASSWORD'
  #KEYCLOAK_REQUIRED_ACTIONS_WEBAUTHN_REGISTER='webauthn-register'$

  ATTRIBUTES={
    GROUP_IDENTIFICATION_NAME: 'group_identification_name',
    CLIENT_IDENTIFICATION_NAME: 'client_identification_name',
    LOCALE: 'locale'
  }

  define_attribute(:username, :username)
  define_attribute(:is_enabled, :enabled)
  define_attribute(:is_email_verified, :emailVerified)
  define_attribute(:first_name, :firstName)
  define_attribute(:last_name, :lastName)
  define_attribute(:email, :email)
  define_attribute(:required_actions, :requiredActions)
  define_attribute(:keycloak_attributes, :keycloak_attributes)
  define_attribute(:has_one_time_password, :totp)
end