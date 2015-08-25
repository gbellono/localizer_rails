Rails.application.routes.draw do

  scope ":locale", :locale => /#{LocalizerRails.active_locales.join("|")}/ do
    root :to => 'static_pages#home'
    get 'page' => 'static_pages#page', :as => :page
    %w( 404 ).each do |code|
      get code, :to => "errors#show", :code => code, :as => "error_#{code}"
    end
  end
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
end
