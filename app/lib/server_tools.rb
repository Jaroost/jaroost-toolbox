# frozen_string_literal: true

class ServerTools
  #Détermine si on est dans une rake task (si Rails::Server n'est pas définie, on est en rake task)
  def self.is_rake_environment?
    !Object.const_defined?('Rails::Server')
  end

  #Détermine si on est sur le port port (dans le cas d'un rake environment retourne false)
  def self.is_current_port?(port)
    if is_rake_environment?
      return false
    end
    current_port=ENV['PORT']&.to_i||3000
    current_port==port
  end

  #Détermine si on est en production
  def self.is_production?
    # TODO
    false
  end

  #Détermine si on est en dévelopment
  def self.is_development?
    # TODO
    true
  end

  #Détermine si on est en test
  def self.is_test?
    # TODO
    false
  end

  def self.is_fast_boot?
    ENV.has_key?("FAST_BOOT")
  end

  #Détermine si on est en VPN
  def self.is_on_vpn?
    # Socket.ip_address_list.select{|ip| ip.ip_address.start_with?('172.16.25')}.any?
    # TODO
    false
  end
end