class CommentsController < ApplicationController

  def index
    class_name = nil
    obj_id     = nil
    params.each_pair do |key, value|
      class_name = key =~ /_id$/ ? key.sub(/_id$/, '').classify : nil
      obj_id     = class_name ? value : nil
      break if class_name && obj_id
    end
    render :nothing => true and return unless class_name && obj_id
    @object   = Module.const_get(class_name).find(obj_id)
    @comments = @object.comments.including_user
    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace "comments_for_#{class_name.underscore}_#{obj_id}",
            :inline => '<%=comments_for(@object, :open => @comments)%>'
        end
      end
    end
  end

  def create
    @comment = Comment.new(params[:comment])
    @object  = @comment.commentable
    if @object.can_comment?(@user)
      @comment.user       = @user
      @comment.ip_address = request.remote_ip
      @comment.save!
      respond_to do |format|
        format.js do
          @comments = @object.comments
          render :update do |page|
            page.replace "comments_for_#{domid(@object)}",
              :inline => '<%=comments_for(@object, :open => @comments)%>'
          end
        end
      end
    else
      render :nothing => true
    end
  end

  def edit
    @comment = Comment.find(params[:id])
    if @comment.can_edit?(@user)
      respond_to do |format|
        format.js do
          render :update do |page|
            page.replace domid(@comment), :inline => '<%=comment_editor(@comment)%>'
          end
        end
      end
    else
      render :nothing => true
    end
  end

  def update
    @comment = Comment.find(params[:id])
    if @comment.can_edit?(@user)
      @comment.update_attributes(params[:comment].merge({ :modified_by => @user.id }))
      respond_to do |format|
        format.js do
          render :update do |page|
            page.replace domid(@comment), :inline => '<%=comment_item(@comment)%>'
          end
        end
      end
    else
      render :nothing => true
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    if @comment.can_edit?(@user)
      @object   = @comment.commentable
      @comments = @object.comments
      @comment.destroy
      respond_to do |format|
        format.js do
          render :update do |page|
            page.replace "comments_for_#{domid(@object)}",
              :inline => '<%=comments_for(@object, :open => @comments)%>'
          end
        end
      end
    else
      render :nothing => true
    end
  end

end
