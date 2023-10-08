class Hash

  #permet de passer en hash des values qui serait du json
  def deep_hashify!
    self.keys.each do |key|
      if self[key].class==String
        begin
          self[key]=JSON.parse(self[key])
        rescue
          nil
        end
      elsif self[key].class==Hash
        self[key].deep_hashify!
      end
    end
  end

  def method_missing(method_name, *args)
    #Permet de récupérer une valeur dans un hash en utilisant une méthode:
    # hash.test --> revient à faire hash[:test] ou hash["test"] si la clé n'existe pas dans le hash génère une exception
    if self.has_key?(method_name)
      self[method_name]
    elsif self.has_key?(method_name.to_s)
      return self[method_name.to_s]
    else
      presumed_key_name = method_name.to_s.delete_suffix('=')
      if self.has_key?(presumed_key_name) && args.length == 1
        return self[presumed_key_name] = args[0]
      elsif self.has_key?(presumed_key_name.to_sym) && args.length == 1
        return self[presumed_key_name.to_sym] = args[0]
      else
        super
      end
    end
  end
end