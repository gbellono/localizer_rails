require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)
require "localizer_rails"

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de


    # rails will fallback to en, no matter what is set as config.i18n.default_locale
#    config.i18n.fallbacks = [:en]

    # fallbacks value can also be a hash - a map of fallbacks if you will
    # missing translations of es and fr languages will fallback to english
    # missing translations in german will fallback to french ('de' => 'fr')
#    config.i18n.fallbacks = {'es' => 'en', 'fr' => 'en', 'de' => 'fr'}

    ## By default rails-i18n loads all locale files. If you want to load only a few files:
    # config.i18n.available_locales = [:en,'es-CO', :de]

## TEST
    # rails will fallback to config.i18n.default_locale translation
    config.i18n.fallbacks = true

    # config.i18n.default_locale = :en
    # config.time_zone = 'Asia/Phnom_Penh'
    # config.time_zone = 'London'
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Rome'
  end
end

