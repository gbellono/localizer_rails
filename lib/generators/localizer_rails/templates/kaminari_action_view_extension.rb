## ADD to the Gemfile:
## add the kaminari pagination (https://github.com/amatsuda/kaminari)
# gem 'kaminari', '~> 0.16'
## add the kaminari translations (https://github.com/tigrish/kaminari-i18n)
# gem 'kaminari-i18n'


## OVERRIDE KAMINARI METHOD to use Rails CLDR (Common Locale Data Repository) pluralization translations
require 'kaminari/helpers/action_view_extension.rb'
module Kaminari
  module ActionViewExtension

    def page_entries_info(collection, options = {})
      ## from a post by https://github.com/Linuus in https://github.com/amatsuda/kaminari/pull/309
      #- entry_name = options[:entry_name] || collection.entry_name
      #- entry_name = entry_name.pluralize unless collection.total_count == 1
      #+ entry_name = collection.model_name.human(:count => collection.total_count, :default => collection.model_name.human.pluralize).downcase
      entry_name = collection.model_name.human(:count => collection.total_count, :default => collection.model_name.human.pluralize).downcase

      if collection.total_pages < 2
        t('helpers.page_entries_info.one_page.display_entries', :entry_name => entry_name, :count => collection.total_count)
      else
        first = collection.offset_value + 1
        last  = collection.last_page? ? collection.total_count : collection.offset_value + collection.limit_value
        t('helpers.page_entries_info.more_pages.display_entries', :entry_name => entry_name, :first => first, :last => last, :total => collection.total_count)
      end.html_safe
    end

  end
end
