# vim: set nowrap:
class BlogPostController < ApplicationController

  def create
    if request.xhr?
      if @user.is_a? User
        post            = BlogPost.new(params[:blog_post])
        post.user       = @user
        post.ip_address = request.env['REMOTE_ADDR']
        if post.user == post.blog.user
          if post.save
            render :update do |page|
              page.insert_html :top, :blog_post_list,
                               :partial => 'editable_blog_post_with_li',
                               :locals  => { :p => post }
              page[:new_blog_post_form].hide
              page[:new_blog_post_link].show
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
        post = BlogPost.find(post_id)
        if post.user == @user
          params[:blog_post].each_pair do |key, value|
            post.send("#{key}=".to_sym, value) if post.respond_to? "#{key}=".to_sym
          end
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
        if post.user == @user
          post.destroy
          render :update do |page|
            page.hide "blog_post_#{post.id}"
          end and return
        end
      end
    end
    render :nothing => true
  end

end
