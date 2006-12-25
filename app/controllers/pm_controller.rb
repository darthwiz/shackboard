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
    @pageseq_opts = { :controller  => 'pm',
                      :action      => 'list',
                      :last        => Pm.count(conds),
                      :current     => start,
                      :ipp         => ppp,
                      :extra_links => [ :first, :forward, :back, :last ] }
  end # }}}
  def css # {{{
    @headers["Content-Type"] = 'text/css; charset = utf-8'
    @theme_name              = params[:id].sub(/\.css$/, "")
    render :partial => 'css'
  end # }}}
  def show # {{{
    unless @user
      render :nothing => true and return
    end
    if @request.xml_http_request?
      @pm = Pm.find(params[:id])
      if @pm.to == @user && !@pm.read?
	@pm.status = 'read'
        @pm.save
      end
    else
      render :nothing => true and return
    end
  end # }}}
  def delete # {{{
    unless @user
      render :nothing => true and return
    end
    if @request.xml_http_request?
      @pm = Pm.find(params[:id])
      if @pm.to == @user
	#@pm.destroy
      end
    else
      render :nothing => true and return
    end
  end # }}}
end
