# vim: set nowrap:
class BlogsController < ApplicationController

  def index
    username = params[:username]
    if username
      @blog_user = User.find_by_username(username)
      if @blog_user.is_a? User
        @blogs = Blog.find(
          :all,
          :conditions => [ 'user_id = ?', @blog_user.id ]
        )
      end
      @location = @blog_user
    else
      blogs            = Blog.all(:order => 'user_id, last_post_at DESC')
      users_with_blogs = User.with_blog.uniq
      @blogs_by_user   = []
      users_with_blogs.each do |u|
        @blogs_by_user << [ u, blogs.select { |i| i.user_id == u.id } ]
      end
      @blogs_by_user.sort! { |b, a| a[1].first.last_post_at.to_i <=> b[1].first.last_post_at.to_i }
      @location = @blogs_by_user.first[1]
    end
  end

  def show
    username   = params[:username]
    label      = params[:blog_label]
    @blog_user = User.find_by_username(username)
    if @blog_user.is_a? User
      conds = [ 'user_id = ? AND label = ?', @blog_user.id, label ]
      @blog = Blog.find(:first, :conditions => conds)
    end
    if @blog.is_a? Blog
      @posts = BlogPost.find(
        :all,
        :conditions => [ 'user_id = ? AND blog_id = ?', @blog_user.id, @blog.id ],
        :order      => 'created_at DESC'
      )
      @page_title = @blog.name
      @blog.increment! :view_count
    end
    @location = @blog
  end

  def edit
    if request.xhr?
      if @user.is_a? User
        blog_id = params[:id]
        blog    = Blog.find(blog_id)
        render :partial => 'blog_editor',
               :locals  => { :blog => blog } and return
      end
    end
    render :nothing => true
  end

  def update
    if request.xhr?
      if @user.is_a? User
        blog_id = params[:blog][:id]
        blog    = Blog.find(blog_id)
        if blog.user == @user
          params[:blog].each_pair do |key, value|
            blog.send("#{key}=".to_sym, value) if blog.respond_to? "#{key}=".to_sym
          end
          if blog.save
            @blog_user = blog.user
            render :partial => 'editable_blog',
                   :locals  => { :blog => blog } and return
          end
        end
      end
    end
    render :nothing => true
  end

  def create
    if request.xhr?
      if @user.is_a? User
        blog       = Blog.new(params[:blog])
        blog.user  = @user
        @blog_user = blog.user
        if blog.save
          render :update do |page|
            page.insert_html :bottom, :blog_list,
                             :partial => 'editable_blog',
                             :locals  => { :blog => blog }
            page[:new_blog_form].hide
            page[:new_blog_link].show
          end and return
        end
      end
    end
    render :nothing => true
  end

  def destroy
    if request.xhr?
      if @user.is_a? User
        blog_id = params[:id]
        blog = Blog.find(blog_id)
        if blog.user == @user
          blog.destroy
          render :update do |page|
            page.hide "blog_#{blog.id}"
          end and return
        end
      end
    end
    render :nothing => true
  end

  def backup
    redirect_to root_path and return unless @user.is_a? User
    @skip_anonymize_filter = true
    @blogs = @user.blogs
    respond_to do |format|
      format.txt { send_data(render_to_string.gsub(/([^\r])\n/, "\\1\r\n"), :filename => 'blogs_backup.txt', :mimetype => 'text/plain') }
      format.sql { send_data(render_to_string.gsub(/([^\r])\n/, "\\1\r\n"), :filename => 'blogs_backup.sql', :mimetype => 'text/plain') }
      format.xml { send_data(render_to_string, :filename => 'blogs_backup.xml', :mimetype => 'text/plain') }
    end
  end

end
