# -*- encoding : utf-8 -*-
require 'airbrake'

filename = File.join Decko.root, 'config/airbrake.yml'
if File.exists? filename or File.symlink? filename
  ab_config  = YAML.load_file(filename).with_indifferent_access
  Airbrake.configure do |config|
    Rails.logger.info "setting up airbrake"
    config.project_key = ab_config[:project_key]
    config.project_id = ab_config[:project_id]
  end
end
