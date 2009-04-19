# vim: set nowrap:
class BlogCommentsController < ApplicationController
  layout 'blog'
  helper :blog

  def show
    comment     = BlogComment.find(params[:id])
    @blog_user  = comment.blog.user
    @blog       = comment.blog
    @posts      = [ comment ]
    @page_title = comment.blog_post.title || comment.blog.title
    @location   = [ 'Blog', @blog ]
    render :template => '/blog/view'
    @blog.increment! :view_count
  end

  def create
    if request.xhr?
      if @user.is_a? User
        comment            = BlogComment.new(params[:blog_comment])
        comment.user       = @user
        comment.ip_address = request.remote_ip
        @blog              = comment.blog_post.blog
        comment.blog_post.increment!(:comments_count)
        if @user != comment.blog.user
          comment.unread = true
          comment.blog_post.increment!(:unread_comments_count)
        end
        if comment.save
          render :update do |page|
            page.insert_html :bottom, "blog_post_#{comment.blog_post_id}_comments_list".to_sym,
                             :partial => '/blog_posts/editable_blog_post_with_li',
                             :locals  => { :p => comment }
            page["new_blog_post_form_#{comment.blog_post_id}".to_sym].hide
            page["new_blog_post_link_#{comment.blog_post_id}".to_sym].show
          end and return
        end
      end
    end
    render :nothing => true
  end

  def edit
    if request.xhr?
      if @user.is_a? User
        id      = params[:id]
        comment = BlogComment.find(id)
        render :partial => '/blog_post/blog_post_editor',
               :locals  => { :p => comment } and return
      end
    end
    render :nothing => true
  end

  def update
    if request.xhr?
      if @user.is_a? User
        id      = params[:blog_comment][:id]
        comment = BlogComment.find(id)
        @blog   = comment.blog
        if @user == comment.user || @user == comment.blog.user
          params[:blog_comment].each_pair do |key, value|
            comment[key] = value
          end
          comment.modified_by = @user.id
          if comment.save
            render :partial => '/blog_post/editable_blog_post',
                   :locals  => { :p => comment } and return
          end
        end
      end
    end
    render :nothing => true
  end

  def destroy
    if request.xhr?
      if @user.is_a? User
        id      = params[:id]
        comment = BlogComment.find(id)
        if @user == comment.user || @user == comment.blog.user
          if comment.destroy
            comment.blog_post.decrement!(:comments_count)
            render :update do |page|
              page.hide "blog_comment_#{comment.id}"
            end and return
          end
        end
      end
    end
    render :nothing => true
  end

end
