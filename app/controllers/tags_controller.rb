class TagsController < ApplicationController
  skip_before_filter :load_defaults, :authenticate, :update_online, :set_stylesheet, :only => [ :set, :edit ]
  layout 'forum'

  def index
    @popular_tags = Tag.find_most_popular(50)
    @location     = @popular_tags
  end

  def edit
    render :nothing => true and return unless @user
    class_name     = params['type']
    id             = params['id'].to_i
    @tagged_object = Module.const_get(class_name).find(id)
    respond_to do |format|
      format.js do
        if @tagged_object.can_tag?(@user)
          render :update do |page|
            page.replace "tag_#{class_name.underscore}_#{id}", :inline => "<%=tag_editor(@tagged_object)%>"
          end
        end
      end
    end
  end

  def set
    render :nothing => true and return unless @user
    class_name     = params['type']
    id             = params['id'].to_i
    tags           = params['tags']
    @tagged_object = Module.const_get(class_name).find(id)
    @tagged_object.tag_with(tags, @user, :absolute => true)
    @tagged_object = Module.const_get(class_name).including_tags.find(id)
    respond_to do |format|
      format.js do
        if @tagged_object.can_tag?(@user)
          render :update do |page|
            page.replace "tag_#{class_name.underscore}_#{id}", :inline => "<%=editable_tags(@tagged_object)%>"
          end
        end
      end
    end
  end

end
