class WelcomeController < ApplicationController

  def index
    respond_to do |format|
      format.html do
        @page_title = "StudentiBicocca.it - il portale degli studenti della Bicocca"
        prepare_modules
      end
      format.js do
        session[:modules]             = {} if session[:modules].blank?
        session[:modules][:primary]   = [] if session[:modules][:primary].blank?
        session[:modules][:secondary] = [] if session[:modules][:secondary].blank?
        session[:modules][:primary]   = params[:modules_primary]   if params[:modules_primary]
        session[:modules][:secondary] = params[:modules_secondary] if params[:modules_secondary]
        logger.debug session[:modules].inspect
        render :nothing => true
      end
    end
  end

  private

  def prepare_modules
    session[:modules] = { :primary => [], :secondary => [] } if session[:modules].blank?
    mods              = session[:modules]
    @modules          = {}
    if mods[:primary].reject(&:blank?).blank?
      forums = [ 70, 69, 61, 67, 52, 57, 59, 55 ]
      session[:modules][:primary] = forums.collect { |i| "forum_#{i}" }.uniq
    end
    @modules[:primary] = parse_modules(session[:modules][:primary])
    if mods[:secondary].reject(&:blank?).blank?
      forums = [ 27, 171, 164, 109 ]
      session[:modules][:secondary] = forums.collect { |i| "forum_#{i}" }.uniq
    end
    @modules[:secondary] = parse_modules(session[:modules][:secondary])
  end

  def parse_modules(module_strings)
    mods = []
    module_strings.reject(&:blank?).uniq.each do |s|
      if s =~ /_[0-9]+$/
        id        = s.sub(/^.*_([0-9]+)$/, "\\1").to_i
        obj_class = s.sub(/^(.*)_([0-9]+)$/, "\\1").classify
        mods << Module.const_get(obj_class).find(id)
      end
    end
    mods
  end

end
