class WelcomeController < ApplicationController
  def index # {{{
    redirect_to :controller => 'forum', :action => 'index'
  end # }}}
end
