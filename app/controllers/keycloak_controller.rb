class KeycloakController < ApplicationController
  TRUE_USER_COOKIE_NAME="_#{ENV['PSP_SERVICE_NAME']}_true_user"
  IMPERSONATE_COOKIE_NAME="_#{ENV['PSP_SERVICE_NAME']}_impersonate"
  def reset_configuration
    authorize! :manage, :all

    Keycloak::Client.reset_representations
    redirect_to :root, notice: I18n.t('keycloak.configuration_reset')
  end

  def impersonate
    authorize_with_true_user! :manage, :all
  end

  def impersonate_logout
    authorize_with_true_user! :manage, :all
    Keycloak::Client.logout_user(current_user.uid)
    redirect_to post_logout_path
  end

  def impersonate_user
    authorize_with_true_user! :manage, :all

    #si pas déjà un true_user on le set
    unless Current.true_user
      #Le cookie qui indique quel utilisateur est le true user
      cookies.signed[TRUE_USER_COOKIE_NAME]={
        value: current_user.id,
        expires: 30.minutes.from_now,
        domain: ENV['APP_PUBLIC_HOST'],
        secure: true,
        http_only: true
      }
      #Un cookie qui indique qu'on impersonate avec comme expiration la session
      cookies.signed[IMPERSONATE_COOKIE_NAME]={
        value: true,
        domain: ENV['APP_PUBLIC_HOST'],
        secure: true,
        http_only: true
      }
    end

    #logout du user courant sur keycloak et ici
    Keycloak::Client.logout_user(current_user.uid)
    reset_session

    #impersonation du user
    rep=Keycloak::Client.impersonate_user(params[:keycloak_user_id])
    response.headers['set-cookie']=rep.headers['set-cookie']

    #redirection
    redirect_back fallback_location: :root
  end

  def change_locale
    current_user.locale=params[:locale] || :en
    Keycloak::Client.update_user_attributes(current_user, attributes:{Keycloak::Representation::User::ATTRIBUTES.LOCALE => current_user.locale})
    current_user.save
    redirect_back fallback_location: :root, notice: I18n.t('keycloak.locale_updated', locale: current_user.locale)
  end

end