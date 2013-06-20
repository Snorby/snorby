# Gives libraries, controllers, models, and views access to the
# settings set in config/snorby_config.yml
# http://stackoverflow.com/questions/592554/best-way-to-create-custom-config-options-for-my-rails-app

APP_CONFIG = YAML.load_file(Rails.root.join('config', 'snorby_config.yml'))[Rails.env]
