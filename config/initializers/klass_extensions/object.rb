class Object
  def send_multi_level(methods_str)
    methods_str.split(".").inject(self){|this, method| this.send(method)}
  end
end