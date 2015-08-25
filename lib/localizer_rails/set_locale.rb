module LocalizerRails
  module SetLocale
    extend self

    def before(arg)
      LocalizerRails.set_locale(arg)
    end
  end
end
