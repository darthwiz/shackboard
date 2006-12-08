class PmController < ApplicationController
  def list # {{{
    unless (@user.is_a? User) then
      redirect_to :controller => 'welcome', :action => 'index' and return
    end
    ppp = @opts[:ppp]
    start = params[:start].to_i
    start = 1 if (start == 0)
    # TODO filter by username or keyword? {{{
    # }}}
    offset = ((start - 1)/ppp)*ppp
    limit  = ppp
    conds  = ["msgto = ? AND folder = 'inbox'", @user.username]
    @pms   = Pm.find :all,
                     :conditions => conds,
                     :order      => 'dateline DESC',
                     :limit      => limit,
                     :offset     => offset
    @pageseq_opts = { :controller => 'pm',
                      :action     => 'list',
                      :first      => 1,
                      :last       => Pm.count(conds),
                      :current    => start,
                      :ipp        => ppp }
  end # }}}
  def css # {{{
    @headers["Content-Type"] = 'text/css; charset = utf-8'
    @theme_name              = params[:id].sub(/\.css$/, "")
    render :partial => 'css'
  end # }}}
end
