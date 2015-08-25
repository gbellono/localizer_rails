module LocalizerRails
  module LocalizerRailsHelper

    def country_or_lang_code(code_sym, lang_name)
      # FLAG images
      lang_name[:country_code].blank? ? code_sym.to_s : lang_name[:country_code].downcase
    end

    def get_lang_name(lang_name)
      which_lang = LocalizerRails::Conf.display_local_language ? :lang_local : :lang_default
      lang_name[which_lang].split(',').first
    end

    def country_code(lang_name, enclose = [])
      # ex: enclose = ['(',')']
      country_code = lang_name[:country_code].upcase
      enclose_string_within(country_code, enclose)
    end

    def render_elements(code_sym, lang_name)
      render :partial => 'localizer_rails/elements', :locals => { :code_sym => code_sym, :lang_name => lang_name }
    end

    def enclose_string_within(str, arr)
      str.blank? || arr.blank? || (arr.count != 2) ? str : "#{arr[0]}#{str}#{arr[1]}"
    end

  end
end
