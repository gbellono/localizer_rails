class LocalizerRails::LocalizerRailsGenerator < Rails::Generators::Base

  def init
    ## INSTALL ALL IF NO OPTION SELECTED
    @has_options = options.any? { |k, v|
      !!v
    }
  end

  source_root File.expand_path(LocalizerRails::Engine.root, __FILE__)

  class_option :views,  :type => :boolean, :default => false, :aliases => "-v", :desc => "[views] Install partials to override the default language dropdown-menu output."
  class_option :routes, :type => :boolean, :default => false, :aliases => "-r", :desc => "[routes] Append (commented hint) code in your route.rb to match *paths without prepended locale."
  class_option :config, :type => :boolean, :default => false, :aliases => "-c", :desc => "[config] Install preference file to change settings for LocalizerRails."
  class_option :map,    :type => :boolean, :default => false, :aliases => "-m", :desc => "[maps] Install the language-country map .yml to edit the translations."
  class_option :nav,    :type => :boolean, :default => false, :aliases => "-n", :desc => "[navigation] Install the bootstrap navbar partial (requires bootstrap gem)."
  class_option :kam,    :type => :boolean, :default => false, :aliases => "-k", :desc => "[pagination] Install Kaminari (v0.16.3) pluralization patch."

  def self.banner
    "rails generate localizer_rails"
  end

  def manifest

    ## == VIEWS
    if options[:views] || !@has_options
      copy_file File.join( *%w( app views localizer_rails _item.html.erb ) ),           ( Rails.root.join( *%w( app views localizer_rails _item.html.erb ) ) )
      copy_file File.join( *%w( app views localizer_rails _item.bootstrap.html.erb ) ), ( Rails.root.join( *%w( app views localizer_rails _item.bootstrap.html.erb ) ) )
      copy_file File.join( *%w( app views localizer_rails _elements.html.erb ) ),       ( Rails.root.join( *%w( app views localizer_rails _elements.html.erb ) ) )
   end

    ## == PREFERENCES
    if options[:config] || !@has_options
      copy_file File.join(*%w( lib generators localizer_rails templates localizer_rails_prefs.rb )), (Rails.root.join(*%w( config initializers localizer_rails localizer_rails_prefs.rb )))
    end

    ## == Language-Country map
    if options[:map] || @all
      copy_file File.join(*%w( config localizer_rails lang_countries.yml )), (Rails.root.join(*%w( config localizer_rails lang_countries.yml )))
    end

    ## == [HANDY] Kaminari pluralization patch (as of v0.16.3)
    if options[:kam] || !@has_options
      copy_file File.join(*%w( lib generators localizer_rails templates kaminari_action_view_extension.rb )), (Rails.root.join(*%w( config initializers kaminari_action_view_extension.rb )))
    end

    ## == [HANDY] Bootstrap 3+ NAVBAR partial
    if options[:nav] || !@has_options
      copy_file File.join(*%w( lib generators localizer_rails templates _header.html.erb )), (Rails.root.join(*%w( app views layouts _header.html.erb )))
    end

    ## == ROUTES
    if options[:routes] || !@has_options
      append_to_file Rails.root.join(*%w( config routes.rb )) do |a|
        %q{
__END__
## --- LocalizerRails routes and match-alls

## (1) move inside your 'locale' scope to create the routes to your custom error pages:
## NOTES:
#   forget about the system error 500, your app might be too broken to handle it

# Rails.application.routes.draw do
    scope ":locale", :locale => /#{LocalizerRails.active_locales.join("|")}/ do
#     ...
      %w( 404 ).each do |code|
        get code, :to => "errors#show", :code => code, :as => "error_#{code}"
      end

## (2) move after your 'locale' scope if you need match-all routes prepending missing locale
## NOTES:
#   - for TESTING POURPOSES in development, REMEMBER to CHANGE this value in config/environments/development
#         config.consider_all_requests_local       = true
#     to:
#         config.consider_all_requests_local       = false
#     => full error reports are disabled, and Rails treats all requests as in production

  match '*path', :to     => redirect { |p, req|
                                       LocalizerRails.set_locale(req)

                                       case
                                       when LocalizerRails.active_locales.none? { |word| req.path.starts_with?("/#{word}/") }
                                         ## TRY prepending the locale
                                         "/#{I18n.locale}#{req.path}"
                                       when Rails.env.production? || !Rails.application.config.consider_all_requests_local
                                         ## SHOW custom 404
                                         Rails.application.routes.url_helpers.error_404_path(:locale => I18n.locale)
                                       else
                                         ## let Rails handle this with default 404
                                         raise ActionController::RoutingError.new('Not Found')
                                       end
                                     },
                 :via    => [ :get, :post, :patch, :delete ],
                 :status => '301'

  match '', :to     => redirect { |p, req| LocalizerRails.set_locale(req) },
            :via    => [:get, :post, :patch, :delete],
            :status => '301'
}
      end
    end
  end

  def show_setup_message
    puts %q{
    Setup done!

    REMEMBER: if you want to test the redirection to your custom pages CHANGE the value in config/environments/development to FALSE:
        config.consider_all_requests_local = false
    and then change it back when you're done testing.

    REMEMBER to IMPORT/REQUIRE the engine's stylesheet
        @import 'localizer_rails/localizer_rails';
      OR
        require localizer_rails
    }
  end
end

