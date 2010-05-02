class WelcomeController < ApplicationController
  skip_before_filter :set_facebook_session,
    :recognize_user, :load_defaults, :set_locale, :set_stylesheet,
    :only => [ :update_modules ]

  def index
    respond_to do |format|
      format.html do
        @page_title = "StudentiBicocca.it - il portale degli studenti della Bicocca"
        prepare_modules
      end
    end
  end

  def update_modules
    respond_to do |format|
      format.js do
        session[:modules]             = {} if session[:modules].blank?
        session[:modules][:primary]   = params[:modules_primary].reject(&:blank?)   unless params[:modules_primary].blank?
        session[:modules][:secondary] = params[:modules_secondary].reject(&:blank?) unless params[:modules_secondary].blank?
        render :nothing => true
      end
    end
  end

  private

  def prepare_modules
    session[:modules] = {} if session[:modules].blank?
    mods              = session[:modules]
    default_modules   = {
      :primary   => Conf.home_page['default_modules']['primary'].split(/\s*,\s*/),
      :secondary => Conf.home_page['default_modules']['secondary'].split(/\s*,\s*/),
    }
    @modules = {
      :primary   => parse_modules(mods[:primary].blank?   ? default_modules[:primary]   : mods[:primary]),
      :secondary => parse_modules(mods[:secondary].blank? ? default_modules[:secondary] : mods[:secondary]),
    }
  end

  def parse_modules(module_strings)
    mods = []
    return [] unless module_strings.is_a?(Array)
    module_strings.reject(&:blank?).uniq.each do |mod_name|
      case mod_name
      when /_[0-9]+$/
        id        = mod_name.sub(/^.*_([0-9]+)$/, "\\1").to_i
        obj_class = mod_name.sub(/^(.*)_([0-9]+)$/, "\\1").classify
        mods << Module.const_get(obj_class).find(id)
      else
        mods << mod_name.to_sym
      end
    end
    mods
  end

end
