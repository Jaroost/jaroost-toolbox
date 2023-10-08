class ApplicationController < ActionController::Base

  before_action :authenticate_user!, :refresh_user_token, :set_must_login, :set_current_attributes
  around_action :set_locale
  def set_locale(&action)
    locale=params[:locale] || current_user.try(:locale) || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  private

  def reset_current_session
    Keycloak::Client.logout_user(current_user.uid) if current_user
    reset_session
    #retrait du true-user
    cookies.signed[KeycloakController::TRUE_USER_COOKIE_NAME]={
      value: nil,
      expires: 3.days.ago,
      domain: ENV['APP_PUBLIC_HOST']
    }

    #On n'impersonate plus
    cookies.signed[KeycloakController::IMPERSONATE_COOKIE_NAME]={
      value: false,
      domain: ENV['APP_PUBLIC_HOST']
    }
  end

  def refresh_user_token
    begin
      Keycloak::Client.refresh_token(current_user)
    rescue Keycloak::Error::RefreshToken => e
      reset_session
      redirect_to post_logout_path
    end
  end

  def set_current_attributes
    Current.user = current_user
    if cookies.signed[KeycloakController::IMPERSONATE_COOKIE_NAME] && !cookies.signed[KeycloakController::TRUE_USER_COOKIE_NAME]
      #déconnection
      reset_current_session
    elsif cookies.signed[KeycloakController::TRUE_USER_COOKIE_NAME]
      Current.true_user= User.find(cookies.signed[KeycloakController::TRUE_USER_COOKIE_NAME])
    else
      Current.true_user=nil
    end
    Current.scope_request(current_user)
  end

  def set_must_login
    @must_login=flash[:alert] == I18n.t('devise.failure.unauthenticated')
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to :root, flash: {error:I18n.t('user.access_denied')}
  end

  def authorize_with_true_user!(action, subject)
    unless can?(action, subject) || (Current.true_user && Ability.new(Current.true_user).can?(action, subject))
      raise CanCan::AccessDenied.new(I18n.t('user.access_denied'), :manage, :all)
    end
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
