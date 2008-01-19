class DraftController < ApplicationController
  before_filter :authenticate
  def list
    unless (@user.is_a? User) then
      redirect_to :controller => 'welcome', :action => 'index' and return
    end
    ppp = @opts[:ppp]
    start = params[:start].to_i
    start = 1 if (start == 0)
    # TODO filter by username or keyword? 
   
    offset  = ((start - 1)/ppp)*ppp
    limit   = ppp
    conds   = ["user_id = ?", @user.id]
    @drafts = Draft.find :all,
      :conditions => conds,
      :order      => 'timestamp DESC',
      :limit      => limit,
      :offset     => offset
    @pageseq_opts = { 
      :controller  => 'draft',
      :action      => 'list',
      :last        => Draft.count(:conditions => conds),
      :current     => start,
      :ipp         => ppp,
      :extra_links => [ :first, :forward, :back, :last ]
    }
    @location = [ 'Draft', :list ]
  end
  def delete
    if request.xml_http_request?
      @draft = Draft.find(params[:id])
      if @draft.user == @user
        @draft.destroy
      end
    else
      render :nothing => true and return
    end
  end
  def css
    headers["Content-Type"] = 'text/css; charset = utf-8'
    @theme_name             = params[:id].sub(/\.css$/, "")
    render :partial => 'css'
  end
end
