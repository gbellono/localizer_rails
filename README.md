LocalizerRails
=========
Just some handy utilities to manage site localization, generator provided

1. set/retrieve language if none selected
2. build language menu (bootstrap 3+ compatible)
3. _[optional]_ convenience partials and Kaminari pluralization patch (up to v0.16.3)

Requirements
------------
Rails version: 4+

**Gemfile**:

    gem 'localizer_rails', '0.1.0'
**Style**:

    @import 'localizer_rails/localizer_rails';
&nbsp;&nbsp;&nbsp;&nbsp;OR

    require localizer_rails


Description
-----------
### **_set_loc_** method

finds the best-match for `I18n.locale` through a cascading search:

1. params[:locale]
2. cookies['locale']
3. current_user.locale (if defined)
4. session[:locale]
5. accepted_locales (scans browser's HTTP_ACCEPT_LANGUAGE)
6. I18n.default_locale (if everything else fails)

and sets values accordingly (cookies, link_to, ...)

1. use in **_before_action_**:

    <pre>before_action LocalizerRails::SetLoc</pre>

2. use in **_routes_**, too:

    <pre>scope ":locale", locale: /#{LocalizerRails.active_locales.join("|")}/ do ...
  ...
  match '*path', to: redirect { |p, req|
                   Localizer.set_locale(req)
                   if( ! (Localizer.active_locales.any? { |word| req.path.starts_with? ("/#{word}/") }) )
                     "/#{I18n.locale}#{req.path}"
                   else
                     if( Rails.env.production? || !Rails.application.config.consider_all_requests_local )
                       ## SHOW custom 404
                       Rails.application.routes.url_helpers.error_404_path(:locale => I18n.locale)
                     else
                       ## let Rails handle this with default 404
                       raise ActionController::RoutingError.new('Not Found')
                     end
                   end
                 },
                 via: [ :get, :post, :patch, :delete ],
                 status: '301'
</pre>

### **_active_locales_map_** method

builds an hash of locale key/value pairs useful to build a `locale_menu`

_[optional]_ override and edit `config/LocalizerRails/lang_countries.yml`

<pre>
:da:
  :lang_default:    'Danish'
  :lang_local:      'Dansk'
  :country_default: 'Denmark'
  :country_local:   'Danmark'
  :country_code:    'DK'
:fo-FO:
  :lang_default:    'Faroese'
  :lang_local:      'Føroyskt'
  :country_default: 'Faroe Islands'
  :country_local:   'Føroyar'
  :country_code:    'FO'
</pre>

_where_

* __:lang_default__: language name in default language (ex.: english)
* __:lang_local__: language name in local language/alphabet

xtra country specs, use if `locale_menu` lists countries instead of languages:

* __:country_default__: country name in default language (english)
* __:country_local__: country name in local language/alphabet
* __:country_code__: country ISO code

**_NOTE_**: languages will be listed ONLY if included in `i18n.available_locales`

_[optional]_ edit **_LI structure_** and attributes in
<pre>app/views/LocalizerRails/_item[.bootstrap].html.erb</pre>

_[optional]_ edit **_LI elements_** and their display order in
<pre>app/views/LocalizerRails/_elements.html.erb</pre>

__CONFIGURATION__

_[optional]_ override and edit `config/initializers/LocalizerRails/LocalizerRails_prefs.rb`

<pre>
LocalizerRails::Conf.configure do |conf|
    conf.variable_name = value
    ...
</pre>

__OPTIONS:__

* __conf.merge_lang_countries_tables__ (boolean)<br/>
if a copy of the `lang_countries.yml` file is found in your application you can force the engine to use ONLY your file or the MERGED hash
    - the engine's file will be used if no override `lang_countries` file is found in your application
    - defaults to **_true_** (= merge files if override file is found)

* __conf.all_available_locales__ (boolean)<br/>
    - set to `true` if
        - you want to load all locales in `I18n.available_locales`
        - you have already selected a limited bunch of locale files to be loaded in `your config.i18n.available_locales = [:en,'es-CO', :de]`
    - set to `false` if you want to specify the locale files in the custom list below (`conf.active_locales`)
    - defaults to **_true_**

    **_Hint:_** install [rails-i18n] (https://github.com/svenfuchs/rails-i18n) to add pluralization rules and a bunch of translated language files.


* __conf.active_locales__ (:sym)<br/>
define which locales your application will use
    - locales not included in `I18n.available_locales` will be ignored
    - defaults to **_[I18n.default_locale]_**

* __conf.country_downcase__ (boolean)<br/>
load locale files depending on your setup:
    - `true`   = use browser's HTTP_ACCEPT_LANGUAGE format (en-us)
    - `false`  = use ISO rules in your `[localefile].yml` (en-US) as in `rails-i18n` locale files
    - defaults to **_false_**

* __conf.display_local_language__ (boolean)<br/>
display menu language names in their own idiom and alphabet or always in the default site language:
    - `true`  = 'Italiano', 'Español', 'Deutsch', ...
    - `false` = 'Italian', 'Spanish', 'German', ... (or whatever language your `config.i18n.default_locale` defaults to)
    - defaults to **_false_**

* __conf.use_bootstrap__ (boolean)<br/>
use bootstrap-style in `locale_menu` (you need to include bootstrap-sass (or similar) in your gemfile and import it in your stylesheet), as opposed to this engine's provided style
    - defaults to **_false_** (= use engine's style)

* __conf.cookie_expires__ (Date | nil)<br/>
set a custom expiration date for the `:cookies[:locale]`
    - Date can be in the format 20.year.from_now.utc (same as cookies.permanent)
    - defaults to **_nil_** (session length)

* __conf.store_in_session__ (boolean)<br/>
store `I18n.locale` also in session?
    - defaults to **_false_**

## Extras (optional)

### **Kaminari override**

[Kaminari] (https://github.com/amatsuda/kaminari) (up to current v0.16.3) handles pluralization through <i>pluralize</i>.<br/>
In case of localization with foreign languages (eventually with multiple plural forms, such as cyrillic) this method often outputs incorrect results.<br/>
The generator installs an override for Kaminari's `ActionViewExtension#page_entries_info`, following a bright hint by <a href="https://github.com/Linuus" target="_blank">Linuus</a> found on <a href="https://github.com/amatsuda/kaminari/pull/309" target="_blank">GitHub</a> (see 'Credits' below).<br/>
The patch uses model_name and AR's count.

**_Note:_** You need to install the [kaminari ~> 0.16] (https://github.com/amatsuda/kaminari) and [kaminari-i18n] (https://github.com/tigrish/kaminari-i18n) gems.

### **Bootstrap 3+ NAVBAR raw partial**
The generator installs a raw partial with the code for a Bootstrap 3+ NAVBAR featuring the language menu, modify it to suit your needs.

**_Note:_** You need to install [bootstrap-sass] (https://github.com/twbs/bootstrap-sass) or a similar gem.

### **dummy app**
Type the following lines in your Terminal application to see a working example:

    $ cd path-to-your-dir
    $ git clone https://github.com/gbellono/localizer_rails.git
    $ cd path-to-your-dir/localizer_rails
    $ bundle install
    $ rails s
Check out comments included in the code.

**_Note:_** to simulate the 'production' error handling remember to set `config.consider_all_requests_local` in `config/environments/development.rb` to `false`.


## Credits

Thanks to [Linuus](https://github.com/Linuus) for suggesting a viable way to patch Kaminari's handling of pluralization issues.

## Copyright

Copyright (c) 2015 by [Giovanni Bellono](mailto://giovanni.bellono@gmail.com)

See [LICENSE](https://github.com/gbellono/localizer_rails/blob/master/MIT-LICENSE) for details.

