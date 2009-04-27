class PmsController < ApplicationController
  before_filter :authenticate
  layout 'forum'

  def index 
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
    @page_seq_opts = { :controller  => :pms,
                       :action      => :index,
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

  def destroy 
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
    reply_id = params[:pm_id].to_i
    draft_id = params[:draft_id].to_i
    if draft_id > 0
      @draft = Draft.secure_find(draft_id, @user)
      @pm    = @draft.object
    else
      @pm    = Pm.new
      @draft = Draft.new(
        :user        => @user,
        :object_type => @pm.class.to_s,
        :object      => @pm
      )
      @draft.save!
    end
    @page_title = 'Nuovo messaggio privato'
    @location = [ 'Pm', :new ]
    render '/posts/new', :layout => 'forum'
  end 

  def reply
    reply_to = Pm.secure_find(params[:id], @user)
    @pm = Pm.new(
      :msgto   => reply_to.msgfrom,
      :message => "[quote]#{reply_to.message}[/quote]\n",
      :subject => reply_to.subject
    )
    @draft = Draft.new(
      :object      => @pm,
      :user        => @user,
      :object_type => @pm.class.to_s
    )
    @draft.save!
    respond_to do |format|
      format.html { render '/posts/new', :layout => 'forum' }
    end
  end

  def post_reply
    reply_to = Post.secure_find(params[:id], @user)
    @pm = Pm.new(
      :msgto   => reply_to.user.username,
      :message => "[quote]#{reply_to.message}[/quote]\n",
      :subject => reply_to.topic.subject
    )
    @draft = Draft.new(
      :object      => @pm,
      :user        => @user,
      :object_type => @pm.class.to_s
    )
    @draft.save!
    respond_to do |format|
      format.html { render '/posts/new', :layout => 'forum' }
    end
  end

  def save_draft 
    # FIXME refactor to use secure_find
    if request.xml_http_request?
      id    = params[:draft_id]
      conds = ['user_id = ?', @user.id]
      d     = Draft.find(id, :conditions => conds ) || Draft.new
      if (d.user == @user)
        d.object             = Pm.new
        d.object.msgfrom = @user.username
        d.object.msgto   = params[:pm][:msgto]
        d.object.message = params[:pm][:message]
        d.object.subject = params[:pm][:subject]
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
      redirect_to pms_path
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
      render :partial => 'pm_index'
    end
  end 

end
