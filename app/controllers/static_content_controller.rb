# vim: set nowrap:
class StaticContentController < ApplicationController
  before_filter :authenticate

  def edit
    if request.xhr?
      if User.admin_ids.include? @user.id
        label = params[:label]
        sc    = StaticContent.find_or_prepare(label)
        render :partial => 'static_content_editor',
               :locals  => { :sc => sc } and return
      end
    end
    render :nothing => true
  end

  def update
    if request.xhr?
      if User.admin_ids.include? @user.id
        sc_hash       = params[:static_content]
        sc            = StaticContent.find_or_prepare(sc_hash[:label])
        sc.text       = sc_hash[:text]
        sc.format     = sc_hash[:format]
        sc.updated_by = @user.id
        sc.save
        render :partial => 'editable_static_content',
               :locals  => { :sc => sc } and return
      end
    end
    render :nothing => true
  end
end
