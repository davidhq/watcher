require 'yaml'

Object.send(:remove_const, :Config)

class Config

  def self.load
    @@config ||= YAML.load_file File.join(File.dirname(__FILE__), 'config.yml')
  end

end
