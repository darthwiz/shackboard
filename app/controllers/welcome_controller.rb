class WelcomeController < ApplicationController
  def index # {{{
  end # }}}
  def css # {{{
    @headers["Content-Type"] = 'text/css; charset = utf-8'
    render :partial => 'css'
  end # }}}
end
