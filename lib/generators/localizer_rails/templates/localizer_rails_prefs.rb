## CUSTOM CONFIGURATION:
## install/copy this file to
#       config/initializers/localizer_rails/
# and uncomment/edit the values you want to customize.

LocalizerRails::Conf.configure do |conf|
  # conf.merge_lang_countries_tables = true
  # conf.all_available_locales = true
  # conf.active_locales = [ :en,
  #                         :'en-GB'
  #                       ]
  # conf.country_downcase = false
  ## DISPLAY LANGUAGE IN ITS OWN IDIOM?
  # conf.display_local_language = false
  ## LOCALE_MENU STYLE
  # conf.use_bootstrap = false
  ## COOKIES
  # conf.cookie_expires = nil                   # ( = session )(default)
  # conf.cookie_expires = 20.year.from_now.utc  # ( = cookies.permanent )
  ## SESSION
  # conf.store_in_session = false
end
