# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  def keycloak
    Rails.logger.debug(JSON.pretty_generate(request.env["omniauth.auth"]))
    begin
      @user = User.from_omniauth(request.env["omniauth.auth"])
    rescue Exception => e
      Rails.logger.fatal "Error while connecting the user #{e.to_s}"
      redirect_to root_path, flash: {error: I18n.t('user.connexion_error')} and return
    end

    if @user.persisted?
      sign_in_and_redirect @user, flash: {error: I18n.t('user.connexion_error')}
    else
      redirect_to root_path, flash: {error: I18n.t('user.connexion_error')}
    end
  end

  def failure
    set_flash_message! :alert, :failure, kind: OmniAuth::Utils.camelize(failed_strategy.name), reason: failure_message
    redirect_to root_path
  end

  #appelé lors de la redirection de keycloak au logout
  def logout
    reset_session
    #retrait du true-user
    cookies.signed[KeycloakController::TRUE_USER_COOKIE_NAME]={
      value: nil,
      expires: 3.days.ago,
      domain: ENV['APP_PUBLIC_HOST']
    }

    #On n'impersonate plus
    cookies.signed[KeycloakController::IMPERSONATE_COOKIE_NAME]={
      value: 0,
      domain: ENV['APP_PUBLIC_HOST']
    }

    redirect_to root_path
  end

  def after_register
  end
end
