# vim: set nowrap:
class BlogPostController < ApplicationController

  def create
    if request.xhr?
      if @user.is_a? User
        post            = BlogPost.new(params[:blog_post])
        post.user       = @user
        post.ip_address = request.env['REMOTE_ADDR']
        if @user != post.blog.user
          post.unread = true
          post.blog_post.increment!(:comments_count)
          post.blog_post.increment!(:unread_comments_count)
        end
        if post.user == post.blog.user || post.blog_post_id > 0
          if post.save
            post.blog.last_post_id = post.id
            post.blog.last_post_at = post.created_at
            post.blog.save
            if post.blog_post_id > 0 # it's a comment
              render :update do |page|
                page.insert_html :bottom, "blog_post_#{post.blog_post_id}_comments_list".to_sym,
                                 :partial => 'editable_blog_post_with_li',
                                 :locals  => { :p => post }
                page["new_blog_post_form_#{post.blog_post_id}".to_sym].hide
                page["new_blog_post_link_#{post.blog_post_id}".to_sym].show
              end and return
            else # it's a post
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
    end
    render :nothing => true
  end

  def edit
    if request.xhr?
      if @user.is_a? User
        post_id = params[:id]
        post = BlogPost.find(post_id)
        conds       = [ 'user_id = ? AND owner_class = ? AND owner_id = ?', @user.id, 'Blog', post.blog.id ]
        @categories = Category.find(:all, :conditions => conds, :order => :name)
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
            if post.blog_post_id > 0
              post.blog_post.decrement!(:comments_count)
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
      @comments   = BlogPost.find(
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
      render :partial => '/blog_post/editable_list',
             :locals  => { :comments    => @comments,
                           :posts       => nil,
                           :parent_post => parent_post } and return
    end
    render :nothing => true
  end

end
