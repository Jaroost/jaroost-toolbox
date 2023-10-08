# require 'omniauth'
# require 'omniauth-oauth2'
# require 'json/jwt'
# require 'uri'

class OmniAuth::Strategies::Keycloak < OmniAuth::Strategies::OAuth2
  class Error < RuntimeError; end
  class ConfigurationError < Error; end
  class IntegrationError < Error; end

  attr_reader :authorize_url
  attr_reader :token_url
  attr_reader :certs


  def setup_phase
    super
    if (@authorize_url.nil? || @token_url.nil?) && !OmniAuth.config.test_mode

      prevent_site_option_mistake

      realm = options.client_options[:realm].nil? ? options.client_id : options.client_options[:realm]
      site = options.client_options[:site]

      raise_on_failure = options.client_options.fetch(:raise_on_failure, false)

      config_url = URI.join(site, "#{auth_url_base}/realms/#{realm}/.well-known/openid-configuration")

      log :debug, "Going to get Keycloak configuration. URL: #{config_url}"
      response = Faraday.get config_url
      if (response.status == 200)
        json = JSON.parse(response.body)

        @certs_endpoint = json["jwks_uri"]
        @userinfo_endpoint = json["userinfo_endpoint"]
        @authorize_url = URI(json["authorization_endpoint"]).path
        @token_url = URI(json["token_endpoint"]).path

        log_config(json)

        options.client_options.merge!({
                                        authorize_url: @authorize_url,
                                        token_url: @token_url
                                      })
        log :debug, "Going to get certificates. URL: #{@certs_endpoint}"
        certs = Faraday.get @certs_endpoint
        if (certs.status == 200)
          json = JSON.parse(certs.body)
          @certs = json["keys"]
          log :debug, "Successfully got certificate. Certificate length: #{@certs.length}"
        else
          message = "Couldn't get certificate. URL: #{@certs_endpoint}"
          log :error, message
          raise IntegrationError, message if raise_on_failure
        end
      else
        message = "Keycloak configuration request failed with status: #{response.status}. " \
                              "URL: #{config_url}"
        log :error, message
        raise IntegrationError, message if raise_on_failure
      end
    end
  end

  def auth_url_base
    return '/auth' unless options.client_options[:base_url]
    base_url = options.client_options[:base_url]
    return base_url if (base_url == '' || base_url[0] == '/')

    raise ConfigurationError, "Keycloak base_url option should start with '/'. Current value: #{base_url}"
  end

  def prevent_site_option_mistake
    site = options.client_options[:site]
    return unless site =~ /\/auth$/

    raise ConfigurationError, "Keycloak site parameter should not include /auth part, only domain. Current value: #{site}"
  end

  def log_config(config_json)
    log_keycloak_config = options.client_options.fetch(:log_keycloak_config, false)
    log :debug, "Successfully got Keycloak config"
    log :debug, "Keycloak config: #{config_json}" if log_keycloak_config
    log :debug, "Certs endpoint: #{@certs_endpoint}"
    log :debug, "Userinfo endpoint: #{@userinfo_endpoint}"
    log :debug, "Authorize url: #{@authorize_url}"
    log :debug, "Token url: #{@token_url}"
  end

  def build_access_token
    verifier = request.params["code"]
    client.auth_code.get_token(verifier,
                               {:redirect_uri => callback_url.gsub(/\?.+\Z/, "")}
                                 .merge(token_params.to_hash(:symbolize_keys => true)),
                               deep_symbolize(options.auth_token_params))
  end

  def request_phase
    super
  end

  uid{ raw_info['sub'] }

  info do
    if raw_info[ENV['PSP_SERVICE_NAME']].nil?
      Rails.logger.fatal "---------------------------------------"
      Rails.logger.fatal "Les informations retournée par keycloak ne contiennent pas de clé avec le nom #{ENV['PSP_SERVICE_NAME']}! (Mettre à jour les scopes!)"
      Rails.logger.fatal "---------------------------------------"
      raise I18n.t("keycloak.errors.missing_information")
    end
    info=raw_info[ENV['PSP_SERVICE_NAME']] || {}
    info.merge({
                 full_name: "#{info['first_name']} #{info['last_name']}"
               })

  end

  extra do
    {
      'raw_info' => raw_info,
      'id_token' => access_token['id_token']
    }
  end

  def raw_info
    id_token_string = access_token.token
    jwks = JSON::JWK::Set.new(@certs)
    JSON::JWT.decode id_token_string, jwks
  end

  OmniAuth.config.add_camelization('keycloak_oauth2', 'KeycloakOauth2')
end