# -*- encoding : utf-8 -*-
require 'airbrake'

filename = File.join Decko.root, 'config/airbrake.yml'
if !Airbrake.configured? && (File.exist?(filename) || File.symlink?(filename))
  Airbrake.configure do |config|
    Rails.logger.info "setting up airbrake"
    YAML.load_file(filename).each_pair do |key, value|
      config.send "#{key}=", value
    end
  end
end
