class Keycloak::Error::RefreshToken < StandardError
  def initialize(msg = "Refresh token failed!")
    super
  end
end