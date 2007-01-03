class PmController < ApplicationController
  before_filter :authenticate
  def list # {{{
    ppp    = @opts[:ppp]
    start  = params[:start].to_i
    folder = params[:folder] || 'inbox'
    start  = 1 if (start == 0)
    offset = ((start - 1)/ppp)*ppp
    limit  = ppp
    conds  = ["msgto = ? AND folder = ?", @user.username, folder]
    @pms   = Pm.find :all,
                     :conditions => conds,
                     :order      => 'dateline DESC',
                     :limit      => limit,
                     :offset     => offset
    @page_seq_opts = { :controller  => 'pm',
                       :action      => 'list',
                       :last        => Pm.count(conds),
                       :current     => start,
                       :ipp         => ppp,
                       :extra_links => [ :first, :forward, :back, :last ] }
    @location = [ 'Pm', folder ]
  end # }}}
  def css # {{{
    @headers["Content-Type"] = 'text/css; charset = utf-8'
    @theme_name              = params[:id].sub(/\.css$/, "")
    render :partial => 'css'
  end # }}}
  def show # {{{
    if @request.xml_http_request?
      @pm = Pm.find(params[:id])
      render :nothing => true and return unless @pm.acl.can_read?(@user)
      if @pm.to == @user && !@pm.read?
        @pm.status = 'read'
        @pm.save
      end
    else
      render :nothing => true and return
    end
  end # }}}
  def delete # {{{
    if @request.xml_http_request?
      @pm = Pm.find(params[:id])
      if @pm.to == @user
        if @pm.folder == 'trash'
          @pm.destroy
        else
          @pm.folder = 'trash'
          @pm.save
        end
      end
    else
      render :nothing => true and return
    end
  end # }}}
  def undelete # {{{
    if @request.xml_http_request?
      @pm = Pm.find(params[:id])
      if (@pm.to == @user && @pm.folder == 'trash')
        @pm.folder = 'inbox'
        if @pm.save
          render :action => 'delete' and return
        end
      end
    end
    render :nothing => true and return
  end # }}}
  def new # {{{
    reply_id = params[:reply].to_i
    draft_id = params[:draft].to_i
    repclass = params[:class]
    @pm      = Pm.new
    case repclass
    when 'pm'
      conds    = [ 'u2uid = ? AND msgto = ? AND folder = ?', reply_id,
        @user.username, 'inbox' ]
      reply_to = Pm.find(:first, :conditions => conds)
    when 'post'
      reply_to = Post.find(reply_id)
    when 'topic'
      reply_to = Topic.find(reply_id)
    end
    if repclass
      reply_to    = Pm.new unless reply_to.acl.can_read?(@user)
      @pm.msgto   = reply_to.user.username
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
    @location = [ 'Pm', :new ]
  end # }}}
  def save_draft # {{{
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
      render :partial => 'save_draft'
    else
      render :nothing => true and return
    end
  end # }}}
  def create # {{{
    @pm = Pm.new(params[:pm])
    @pm.dateline = Time.now.to_i
    @pm.folder   = 'inbox'
    @pm.status   = 'new'
    @pm.msgfrom  = @user.username
    if @pm.save
      Draft.destroy(params[:draft_id])
      redirect_to :controller => 'pm', :action => 'list'
    else
      draft = Draft.find(params[:draft_id])
      @pm.attribute_names.each do |a|
        draft.object.send(a + '=', @pm.send(a)) if draft.object.respond_to? a
      end
      draft.save
      redirect_to :back
    end
  end # }}}
  def search # {{{
    if @request.xml_http_request?
      ppp    = @opts[:ppp]
      start  = params[:start].to_i
      start  = 1 if (start == 0)
      offset = ((start - 1)/ppp)*ppp
      limit  = ppp
      @pms   = Pm.find_all_by_words @user,
        params[:search].scan_words,
        :order      => 'dateline DESC',
        :limit      => limit,
        :offset     => offset
      render :partial => 'pm_list'
    end
  end # }}}
end
