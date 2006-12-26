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
  def new # {{{
    reply_id = params[:reply].to_i
    draft_id = params[:draft].to_i
    @pm      = Pm.new
    if reply_id > 0
      conds = [ 'u2uid = ? AND msgto = ? AND folder = ?', reply_id,
        @user.username, 'inbox' ]
      reply_to    = Pm.find(:first, :conditions => conds)
      @pm.msgto   = reply_to.msgfrom
      @pm.subject = reply_to.subject
      @pm.format  = reply_to.format
      @pm.message = (reply_to.format == 'bb') ? 
        "[quote]\n" + reply_to.message + "\n[/quote]" : reply_to.message
    end
    if draft_id > 0
      conds  = [ 'id = ? AND object_type = ? AND user_id = ?', draft_id, 'Pm',
        @user.id ]
      @draft = Draft.find(:first, :conditions => conds) || Draft.new
      @pm    = @draft.object if @draft.object
    else
      @draft           = Draft.new
      @draft.user      = @user
      @draft.timestamp = Time.now.to_i
      @draft.object    = @pm
      @draft.save
    end
  end # }}}
  def save_draft # {{{
    unless @user
      render :nothing => true and return
    end
    if @request.xml_http_request?
      Pm.new # this is needed to load the Pm class, otherwise d.object won't be
             # an instance of Pm, but of YAML::Object instead
      id    = params[:draft_id]
      conds = ['user_id = ?', @user.id]
      d     = Draft.find(id, :conditions => conds ) || Draft.new
      if (d.user == @user)
        d.object.msgfrom  = @user.username
        d.object.msgto    = params[:pm][:msgto]
        d.object.message  = params[:pm][:message]
        d.object.subject  = params[:pm][:subject]
        d.object.format   = params[:pm][:format]
        d.timestamp       = Time.now.to_i
        d.save
      end
      @draft = d
    end
  end # }}}
  def create # {{{
    @pm = Pm.new(params[:pm])
    @pm.dateline = Time.now.to_i
    @pm.folder   = 'inbox'
    @pm.msgfrom  = @user.username
    if @pm.save
      Draft.destroy(params[:draft_id])
      redirect_to :controller => 'pm', :action => 'list'
    end
  end # }}}
end
