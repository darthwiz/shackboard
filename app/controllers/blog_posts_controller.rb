# vim: set nowrap:
class BlogPostsController < ApplicationController
  layout 'blogs'
  helper :blogs

  def show
    post        = BlogPost.find(params[:id])
    @blog_user  = post.blog.user
    @blog       = post.blog
    @posts      = [ post ]
    @page_title = post.title || post.blog.title
    @location   = post
    @comments   = post.comments
    render :template => '/blogs/show'
    @blog.increment! :view_count
  end

  def create
    if request.xhr?
      if @user.is_a? User
        post            = BlogPost.new(params[:blog_post])
        post.user       = @user
        post.ip_address = request.remote_ip
        @blog           = post.blog
        if @user != post.blog.user
          post.unread = true
          post.blog_post.increment!(:unread_comments_count)
        end
        if post.user == post.blog.user || post.blog_post_id > 0
          if post.save
            post.tag_with(post.instance_variable_get(:@tags_as_text), @user, :absolute => true)
            post.blog.last_post_id = post.id
            post.blog.last_post_at = post.created_at
            post.blog.save
            render :update do |page|
              page.insert_html :top, :blog_post_list,
                               :partial => 'editable_blog_post_with_li',
                               :locals  => { :p => post }
              page[:new_blog_post_form_0].hide
              page[:new_blog_post_link_0].show
            end and return
          end
        end
      end
    end
    render :nothing => true
  end

  def edit
    if request.xhr?
      if @user.is_a? User
        post_id = params[:id]
        post  = BlogPost.find(post_id)
        conds = [ 'user_id = ? AND owner_class = ? AND owner_id = ?', @user.id, 'Blog', post.blog.id ]
        render :partial => 'blog_post_editor',
               :locals  => { :p => post } and return
      end
    end
    render :nothing => true
  end

  def update
    if request.xhr?
      if @user.is_a? User
        post_id = params[:blog_post][:id]
        post    = BlogPost.find(post_id)
        @blog   = post.blog
        if @user == post.user || @user == post.blog.user
          params[:blog_post].each_pair do |key, value|
            post.send("#{key}=".to_sym, value) if post.respond_to? "#{key}=".to_sym
          end
          post.modified_by = @user.id
          if post.save
            post.tag_with(post.instance_variable_get(:@tags_as_text), @user, :absolute => true)
            render :partial => 'editable_blog_post',
                   :locals  => { :p => post } and return
          end
        end
      end
    end
    render :nothing => true
  end

  def destroy
    if request.xhr?
      if @user.is_a? User
        post_id = params[:id]
        post = BlogPost.find(post_id)
        if @user == post.user || @user == post.blog.user
          if post.destroy
            new_last_post = BlogPost.find(
              :first,
              :conditions => [ 'blog_id = ?', post.blog.id ],
              :order      => 'created_at DESC'
            )
            if new_last_post.is_a? BlogPost
              new_last_post.blog.last_post_id = new_last_post.id
              new_last_post.blog.last_post_at = new_last_post.created_at
              new_last_post.blog.save
            else
              post.blog.last_post_id = nil
              post.blog.last_post_at = nil
              post.blog.save
            end
            render :update do |page|
              page.hide "blog_post_#{post.id}"
            end and return
          end
        end
      end
    end
    render :nothing => true
  end

  def view_comments
    if request.xhr?
      post_id     = params[:id]
      parent_post = BlogPost.find(post_id)
      @blog       = parent_post.blog
      @comments   = BlogComment.find(
        :all,
        :conditions => [ 'blog_post_id = ?', post_id ],
        :order      => 'created_at'
      )
      if @user == @blog.user
        @comments.each do |i|
          i.unread = false
          i.save
        end
        parent_post.unread_comments_count = 0
        parent_post.save
      end
      render :partial => '/blog_posts/editable_list',
             :locals  => { :comments    => @comments,
                           :posts       => nil,
                           :parent_post => parent_post } and return
    end
    render :nothing => true
  end

end
