class PostsController < ApplicationController
  before_filter :authenticate, :except => [ :show, :search ]
  layout 'forum'

  def show
    @post         = Post.secure_find(params[:id], @user)
    @page_title   = @post.topic.title
    @post.message = '[ messaggio cancellato ]' if @post.deleted_by && !@user.is_adm?
    respond_to do |format|
      format.html do
        @location   = @post
        @page_title = @post.topic.title
      end
      format.xml { render :xml => @post }
    end
  end

  def reply
    reply_to = Post.secure_find(params[:id], @user)
    @topic   = reply_to.topic
    @post    = Post.new(
      :topic        => @topic,
      :reply_to_pid => reply_to.pid,
      :reply_to_uid => reply_to.uid,
      :message      => "[quote][b]Originariamente inviato da #{reply_to.user.username}[/b]\n#{reply_to.message}[/quote]\n"
    )
    @draft = Draft.new(:object => @post, :user => @user)
    @draft.save!
    respond_to do |format|
      format.html do
        @latest_posts = @topic.latest_posts(10).reverse
        render :action => 'new'
      end
    end
  end

  def new
    draft_id = params[:draft_id].to_i
    topic_id = params[:topic_id].to_i
    Post.new
    Topic.new
    if draft_id > 0
      @draft = Draft.secure_find(draft_id, @user)
      @topic = @draft.object.topic if @draft.object.topic_id > 0
      @post  = @draft.object
    elsif topic_id > 0
      @topic = Topic.secure_find(topic_id, @user)
      @post  = Post.new(
        :topic => @topic,
        :reply_to_pid => 0,
        :reply_to_uid => 0
      )
      @draft = Draft.new(:object => @post, :user => @user)
      @draft.save!
    end
    respond_to do |format|
      format.html do
        @latest_posts = @topic.latest_posts(10).reverse
        @location     = @post
        @page_title   = "Nuovo messaggio in \"#{@post.topic.title}\""
      end
    end
  end

  def edit
    @post  = Post.secure_find_for_edit(params[:id], @user)
    @topic = @post.topic
    ## TODO we don't use drafts on editing right now
    #@draft = Draft.new(
    #  :object      => @post,
    #  :user        => @user
    #)
    #@draft.save!
    respond_to do |format|
      format.html { render :action => 'new' }
    end
  end

  def save_draft
    @draft        = Draft.secure_find(params[:draft_id], @user)
    @draft.object = Post.new(params[:post])
    @draft.save
    respond_to do |format|
      format.html { render :partial => '/drafts/save_draft' }
    end
  end

  def create
    @post  = Post.new(params[:post])
    @draft = Draft.secure_find(params[:draft_id], @user)
    if @post.topic.can_post?(@user)
      @post.dateline = Time.now.to_i
      @post.useip    = request.remote_ip
      @post.usesig   = 'yes'
      @post.forum    = @post.topic.forum
      @post.user     = @user
      @post.save!
      @draft.destroy
      respond_to do |format|
        format.html { redirect_to topic_path(@post.topic, :page => 'last', :anchor => 'last_post') }
      end
      @post.topic.update_last_post!(@post)
      @post.forum.update_last_post!(@post)
      @post.user.increment!(:postnum)
      cache_expire({:object => :topic, :id => @post.topic.id})
    end
  end

  def update
    @post  = Post.secure_find_for_edit(params[:post][:id], @user)
    #@draft = Draft.secure_find(params[:draft_id], @user) # TODO support drafts
    if @post.can_edit?(@user)
      @post.edituser = @user.id
      @post.editdate = Time.now.to_i
      @post.message  = params[:post][:message]
      @post.save!
      #@draft.destroy
      respond_to do |format|
        format.html { redirect_to topic_path(@post.topic, :start => @post.find_seq, :anchor => "pid#{@post.id}") }
      end
    end
  end

  def destroy
    @post = Post.secure_find_for_edit(params[:id], @user)
    if @post.can_edit?(@user)
      seq = [ @post.find_seq - 2, 0 ].max
      pid = @post.topic.posts_range(seq..seq).first.id
      @post.delete(@user)
      cache_expire({:object => :topic, :id => @post.topic.id})
      respond_to do |format|
        format.html { redirect_to topic_path(@post.topic, :start => seq, :anchor => "pid#{pid}") }
      end
    end
  end

  def backup
    @skip_anonymize_filter = true
    redirect_to root_path unless @user.is_a? User
    @posts = Post.find(
      :all,
      :conditions => { :uid => @user.id },
      :include    => :topic,
      :joins      => [ :topic ],
      :order      => 'dateline'
    )
    respond_to do |format|
      format.txt { send_data(render_to_string.gsub(/([^\r])\n/, "\\1\r\n"), :filename => 'posts_backup.txt', :mimetype => 'text/plain') }
      format.sql { send_data(render_to_string.gsub(/([^\r])\n/, "\\1\r\n"), :filename => 'posts_backup.sql', :mimetype => 'text/plain') }
      format.xml { send_data(render_to_string(:xml => @posts), :filename => 'posts_backup.xml', :mimetype => 'application/xml') }
    end
  end

  def search
    @query_string  = params[:q].to_s
    @username      = params[:username]
    @time          = params[:time] || 'week'
    time           = { 'all' => 0, 'year' => 1.year.ago, 'month' => 1.month.ago, 'week' => 1.week.ago }
    after          = time[@time]
    user           = User.find_by_username(@username)
    qs             = QueryString.new(@query_string).to_mysql
    ppp            = @opts[:ppp]
    start          = params[:start].to_i - 1
    start          = 0 if (start <= 0)
    rstart         = (start/ppp)*ppp
    rend           = rstart + ppp - 1
    finder         = Post.public_only.after_time(after)
    finder         = finder.with_matching_text(qs) unless @query_string.blank?
    finder         = finder.with_user(user) unless @username.blank?
    @posts_count   = finder.count
    @range         = rstart..rend
    @posts         = finder.range(@range).including_user.including_topic.ordered_by_time_desc
    @location      = :search_results
    @page_seq_opts = { :last        => @posts_count,
                       :ipp         => ppp,
                       :current     => start + 1,
                       :get_parms   => [ :q, :time, :username ],
                       :extra_links => [ :first, :forward, :back, :last ] }
  end

  def report
    @post       = Post.secure_find(params[:id])
    @location   = [ :report, @post ]
    @page_title = "Segnalazione messaggio"
    save_intended_action
  end

  def send_report
    @post    = Post.secure_find(params[:id])
    text     = params[:report][:text]
    username = @user ? @user.username : nil
    title    = "Segnalazione messaggio nella discussione \"#{@post.topic.title}\""
    message  = post_url(@post) + "\n\n" + text
    @post.topic.forum.moderators.each do |mod|
      Pm.new(
        :msgfrom  => username,
        :msgto    => mod.username,
        :subject  => title,
        :message  => message,
        :dateline => Time.now.to_i,
        :folder   => 'inbox',
        :status   => 'new'
      ).save!
    end
    flash[:success] = "La tua segnalazione è stata inviata ai moderatori."
    redirect_to_intended_action
  end

end
