require 'yaml'

def silence_warnings(&block)
  warn_level = $VERBOSE
  $VERBOSE = nil
  result = block.call
  $VERBOSE = warn_level
  result
end

silence_warnings { Object.send(:remove_const, :Config) if Object.const_defined?('Config') }

class Config

  def self.load
    @@config ||= YAML.load_file File.join(File.dirname(__FILE__), 'config.yml')
  end

end
