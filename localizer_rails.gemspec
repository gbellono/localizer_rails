$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "localizer_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "localizer_rails"
  s.version     = LocalizerRails::VERSION
  s.authors     = ["giovanni bellono"]
  s.email       = ["giovanni.bellono@gmail.com"]
  s.homepage    = "https://github.com/gbellono/localizer_rails"
  s.summary     = "Rails engine - sets best-match I18n.locale and builds locale_menu (Bootstrap 3+ supported)."
  s.description = "Rails engine - sets the I18n.locale through a cascading best-match search and builds the locale_menu (Bootstrap 3+ supported)."
  s.license     = "MIT"

  s.require_paths = ["lib"]
  s.files = Dir["MIT-LICENSE",
                "Rakefile",
                "README.md",
                "{app/assets/images,app/assets/stylesheets,app/helpers,app/views/localizer_rails,config,lib}/**/*"
               ]

  s.add_dependency 'rails', '~> 4.2'
  # s.add_dependency 'rails-i18n', '~> 4.0'

  # s.add_development_dependency 'rake'
  s.add_development_dependency 'bundler', '~> 1.7'
end
