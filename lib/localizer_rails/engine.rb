require "localizer_rails/version"

module LocalizerRails
  class Engine < ::Rails::Engine
    isolate_namespace LocalizerRails

    ## LOAD HELPER
    initializer 'localizer_rails.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        # helper LocalizerRails::LocalizerRailsHelper
        helper LocalizerRails::Engine.helpers
      end
    end
  end
end
