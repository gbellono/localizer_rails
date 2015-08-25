require "localizer_rails/engine"
require "localizer_rails/set_locale"

module LocalizerRails
  extend self

  ##================== CONFIGURATION DEFAULT SETTINGS & USER PREFS

  Conf = OpenStruct.new :merge_lang_countries_tables => true,
                        :all_available_locales       => true,
                        :active_locales              => [ I18n.default_locale ],
                        :country_downcase            => false,
                        :display_local_language      => false,
                        :use_bootstrap               => false,
                        :cookie_expires              => nil,
                        :store_in_session            => false

  def Conf.configure(*, &block)
    block.call self
  end

  # Allows LocalizerRails.method instead of LocalizerRails::Conf.method
  def method_missing(meth, *args, &block)
    Conf.respond_to?(meth) ? Conf.send(meth, *args, &block) : super
  end

  ##==============================================================

  ## DEFINE WHICH LOCALES SHOULD BE AVAILABLE TO THE APPLICATION:
  def active_locales
    @active_locales_temp ||= begin
      if Conf.all_available_locales.blank?
        I18n.available_locales & Conf.active_locales
      else
        I18n.available_locales
      end
    end
  end

  ## FIND BEST-MATCH LOCALE:
  def set_locale(req)
    I18n.locale = req.params[:locale] ||
                  req.send(:cookies)['locale'] ||
                  (req.current_user.locale if (!!(defined? req.current_user.locale))) ||
                  req.session[:locale] ||
                  accepted_locales(req.env['HTTP_ACCEPT_LANGUAGE']) ||
                  I18n.default_locale
    ## FALLBACK IF INVALID DATA IN COOKIES, ...
    I18n.locale = I18n.default_locale unless active_locales.include?(I18n.locale)
    ## SET COOKIE:
    req.send(:cookies)[:locale]                           = { :value   => I18n.locale,
                                                              :expires => Conf.cookie_expires
                                                            }
    ## SET SESSION:
    req.send(:session)[:locale]                           = I18n.locale unless Conf.store_in_session.blank?
    ## LOCALIZE LINKS
    Rails.application.routes.default_url_options[:locale] = I18n.locale

    ## RETURN LOCALE:
    I18n.locale
  end

  PATH_TO_LANG = %w[ config localizer_rails lang_countries.yml ]

  ## BUILD LOCALE MAP:
  def active_locales_map
    @my_locales_ok ||= begin
                          custom_file_path = Rails.root.join(*PATH_TO_LANG)
                          loc_map          = if File.exist?(custom_file_path)
                                               if Conf.merge_lang_countries_tables
                                                 lang_file(Engine).merge(lang_file(Rails))
                                               else
                                                 lang_file(Rails)
                                               end
                                             else
                                               lang_file(Engine)
                                             end

                          my_locales_temp  = {}

                          if Conf.all_available_locales.blank?
                            active_locales.each do |k|
                              next unless I18n.available_locales.include?(k) && loc_map.key?(k)
                              my_locales_temp[k] = loc_map[k]
                            end

                          else
                            I18n.available_locales.each do |k|
                              next unless loc_map.key?(k)
                              my_locales_temp[k] = loc_map[k]
                            end
                          end
                          my_locales_temp
                        end
  end

  private

  def lang_file(what)
    YAML.load( File.read(what.root.join(*PATH_TO_LANG)) )
  end

  ## FIND HTTP_ACCEPT_LANGUAGE best-match locale
  def accepted_locales(http_accept_language)
    return false if http_accept_language.blank?

    langs = http_accept_language.scan(/([a-zA-Z]{2,4})(?:(-[a-zA-Z]{2}))?(?:;q=(1|0?\.[0-9]{1,3}))?/).map do |pair|

      lang, country, q = pair

      ccase     = Conf.country_downcase.blank? ? :upcase : :downcase
      # try to create lang-country pair
      lang_test = lang + country.try(ccase).to_s

      # match against active locales and use pair if exist
      lang = lang_test if active_locales_map.include?(lang_test.to_sym)
      # add preference q=1.0 if missing
      [lang.to_sym, (q || '1').to_f]
    end

    # sort by preference
    langs.sort_by { |lang, q| q }.map { |lang, q| lang }.reverse
    # return first choice
    langs.first[0]
  end
end
