class PmController < ApplicationController
  before_filter :authenticate
  layout 'forum'

  def list 
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
                       :last        => Pm.count(:conditions => conds),
                       :current     => start,
                       :ipp         => ppp,
                       :extra_links => [ :first, :forward, :back, :last ] }
    @location = [ 'Pm', folder ]
    render :layout => 'forum'
  end 

  def show 
    if request.xml_http_request?
      @pm = Pm.find(params[:id])
      render :nothing => true and return unless @pm.can_read?(@user)
      if @pm.to == @user && !@pm.read?
        @pm.status = 'read'
        @pm.save
      end
    end
    render :nothing => true and return
  end 

  def delete 
    if request.xml_http_request?
      @pm = Pm.find(params[:id])
      if @pm.to == @user
        if @pm.folder == 'trash'
          @pm.destroy
        else
          @pm.folder = 'trash'
          @pm.save
        end
      end
    end
    render :nothing => true and return
  end 

  def undelete 
    if request.xml_http_request?
      @pm = Pm.find(params[:id])
      if (@pm.to == @user && @pm.folder == 'trash')
        @pm.folder = 'inbox'
        @pm.save
      end
    end
    render :nothing => true and return
  end 

  def new 
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
    end
    if repclass
      reply_to    = Pm.new unless reply_to.can_read?(@user)
      @pm.msgto   = reply_to.user.username
      @pm.subject = reply_to.subject
      @pm.format  = reply_to.format
      @pm.message = (reply_to.format == 'bb') ? 
        "[quote]" + reply_to.message + "[/quote]" : reply_to.message
    else
      @pm.msgto = params[:msgto]
    end
    if draft_id > 0
      conds  = [ 'id = ? AND object_type = ? AND user_id = ?', draft_id, 'Pm',
        @user.id ]
      @draft = Draft.find(:first, :conditions => conds) || Draft.new
      @pm    = @draft.object[0] if @draft.object && @draft.object[0]
    else
      @draft             = Draft.new
      @draft.user        = @user
      @draft.timestamp   = Time.now.to_i
      @draft.object      = [ @pm ]
      @draft.object_type = @pm.class.to_s
      @draft.save!
    end
    @page_title = 'Nuovo messaggio privato'
    @location = [ 'Pm', :new ]
  end 

  def save_draft 
    if request.xml_http_request?
      id    = params[:draft_id]
      conds = ['user_id = ?', @user.id]
      d     = Draft.find(id, :conditions => conds ) || Draft.new
      if (d.user == @user)
        d.object             = [ Pm.new ]
        d.object[0].msgfrom  = @user.username
        d.object[0].msgto    = params[:pm][:msgto]
        d.object[0].message  = params[:pm][:message]
        d.object[0].subject  = params[:pm][:subject]
        d.object[0].format   = params[:pm][:format]
        d.timestamp          = Time.now.to_i
        d.save
      end
      @draft = d
      render :partial => 'save_draft'
    else
      render :nothing => true and return
    end
  end 

  def create 
    @pm = Pm.new(params[:pm])
    @pm.dateline = Time.now.to_i
    @pm.folder   = 'inbox'
    @pm.status   = 'new'
    @pm.msgfrom  = @user.username
    if @pm.save
      Draft.destroy(params[:draft_id]) # FIXME need better security here
      redirect_to :controller => 'pm', :action => 'list'
    else
      draft = Draft.find(params[:draft_id])
      @pm.attribute_names.each do |a|
        if (draft.object.is_a?(Array) && draft.object[0].respond_to?(a))
          draft.object[0].send(a + '=', @pm.send(a)) 
        end
      end
      draft.save
      redirect_to :back
    end
  end 

  def search 
    if request.xml_http_request?
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
  end 

end
