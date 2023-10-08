class Silencer
  def self.silent_block
    if block_given?
      old_level=Rails.logger.level
      Rails.logger.level=Logger::ERROR
      begin
        yield
      ensure
        Rails.logger.level=old_level
      end
    end
  end
end