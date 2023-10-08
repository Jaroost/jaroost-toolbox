class HomeController < ApplicationController

  #On autorise l'utilisateur à ne pas être connecté uniquement sur l'action welcome
  skip_before_action :authenticate_user!, only: [:welcome]

  def signed_welcome
  end

  def welcome
  end

  def test
    if current_user.nil?
      redirect_to root_path
      return
    end

    hash = {
      filters: {
        created_at: {
                       type: '<',
                       search: '01.01.2024'
                     },
        name: {
          type: 'LIKE',
          search: "*"
        },
        id: {
          type: 'AND',
          filters: [
            {
              type: '<',
              search: '200'
            },
            {
              type: '>',
              search: '20'
            },
          ]
        }
      },
      limit: 100,
      model: 'Client',
      orders: [{column: 'name', direction: :asc}],
      offset: 0,
      user: current_user,
      custom_method: {
        method_name: 'index',
        params: []
      }
    }
    @request = Entity::Request.new(hash)
    @search = Entity::GridSearch.new @request
    Client
    builder = @search.query_builder
    @relation = builder.assembled_query
    @response = @search.search
  end
  
  # def index
  #   # ENV['PSP_KEYCLOAK_SITE']="https://keycloak.ptm.net"
  #   # ENV['PSP_KEYCLOAK_BASE_URL']=""
  #   # ENV['KEYCLOAK_ADMIN_PASSWORD']="Z1Pl463fdXUgGmO1p2HI"
  #   # ENV['KEYCLOAK_ADMIN_USER']="admin-psp-dev"
  #
  #   @token_response=Faraday.new(url: ENV['PSP_KEYCLOAK_SITE']).post("#{ENV['PSP_KEYCLOAK_BASE_URL']}/realms/master/protocol/openid-connect/token", {grant_type: :password, client_id: 'admin-cli', password: ENV['KEYCLOAK_ADMIN_PASSWORD'], username: ENV['KEYCLOAK_ADMIN_USER']})
  #   @access_token=JSON.parse(@token_response.body).symbolize_keys![:access_token]
  #
  #
  #   #groups
  #
  #   #@response=JSON.parse(Faraday.new(url: ENV['PSP_KEYCLOAK_SITE']).get("#{ENV['PSP_KEYCLOAK_BASE_URL']}/admin/realms/#{ENV['PSP_KEYCLOAK_REALM']}/groups", nil, {'Authorization': "bearer #{@access_token}"}).body)
  #
  #   #users
  #   #@response=JSON.parse(Faraday.new(url: ENV['PSP_KEYCLOAK_SITE']).get("#{ENV['PSP_KEYCLOAK_BASE_URL']}/admin/realms/#{ENV['PSP_KEYCLOAK_REALM']}/users", nil, {'Authorization': "bearer #{@access_token}"}).body)
  #   # @response=Faraday.new(url: ENV['PSP_KEYCLOAK_SITE']).post("#{ENV['PSP_KEYCLOAK_BASE_URL']}/admin/realms/#{ENV['PSP_KEYCLOAK_REALM']}/users") do |request|
  #   #   request.headers[:content_type] = 'application/json'
  #   #   request.headers[:authorization] = "bearer #{@access_token}"
  #   #   request.body=JSON.generate(email:'test6@test.com', firstName: 'test', lastName: 'test', credentials: [{"type":"password","value":"test5","temporary":true}], enabled: true)
  #   # end.body
  #
  #
  #   # if current_user
  #   #   @response=Faraday.new(url: ENV['PSP_KEYCLOAK_SITE']).post("#{ENV['PSP_KEYCLOAK_BASE_URL']}/realms/#{ENV['PSP_KEYCLOAK_REALM']}/protocol/openid-connect/token") do |request|
  #   #     request.headers['Content-Type']='application/x-www-form-urlencoded'
  #   #     request.body = URI.encode_www_form({
  #   #                                          client_id: 'psp',
  #   #                                          grant_type: 'refresh_token',
  #   #                                          refresh_token: current_user.refresh_token,
  #   #                                          client_secret: ENV['PSP_KEYCLOAK_CLIENT_SECRET']
  #   #                                        })
  #   #
  #   #   end
  #   #
  #   #   if @response.status!=200
  #   #     reset_session
  #   #     redirect_to post_logout_path
  #   #   end
  #   # end
  #   if current_user
  #
  #   end
  # end

  def after_login
    redirect_to root_path
  end

end
# class HomeController < ApplicationController
#
#   SITE=
#
#     def initialize
#       @client=OAuth2::Client.new(
#         "PSP",
#         "4LA2PaaYvsVfvE54TEyPJyP58H6XuJtH",
#         site: "http://localhost:8080/realms/Test",
#         authorize_url: "/realms/Test/protocol/openid-connect/auth",
#         token_url: "/realms/Test/protocol/openid-connect/token"
#       )
#     end
#   def after_login
#     @client=OAuth2::Client.new(
#       "PSP",
#       "4LA2PaaYvsVfvE54TEyPJyP58H6XuJtH",
#       site: "http://keycloak:8080/realms/Test",
#       authorize_url: "/realms/Test/protocol/openid-connect/auth",
#       token_url: "/realms/Test/protocol/openid-connect/token"
#     )
#     token=@client.auth_code.get_token(params.permit![:code], redirect_uri: 'http://localhost:3000')
#     begin
#       decoded=begin
#                 JWT.decode(
#                   token.to_hash[:access_token],
#                   nil,
#                   false,
#                   {
#                     verify_iss: true,
#                     iss: "http://localhost:8080",
#                     verify_aud: true,
#                     aud: @client.id,
#                     algorithm: 'RS256'})
#               rescue JWT::VerificationError
#                 puts "verification error"
#                 raise
#               rescue JWT::DecodeError
#                 puts "bad stuff happened"
#                 raise
#               end
#     rescue Exception => error
#       "An unexpected exception occurred: #{error.inspect}"
#       head :forbidden
#       return
#     end
#     @token=token
#     #token.
#     @decode=decoded
#     session[:user_jwt] = {value: decoded, httponly: true}
#     redirect_to root_path
#   end
#   def test
#
#
#     @login_url=@client.auth_code.authorize_url
#
#
#     #@access_token = client.client_credentials.get_token
#     #    @token=client.auth_code.get_token('user','user')
#     #@token=client.password.get_token("user", "user")
#   end
# end