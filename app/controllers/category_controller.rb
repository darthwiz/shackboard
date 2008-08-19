# vim: set nowrap:
class CategoryController < ApplicationController
  def create
    if request.xhr?
      if @user.is_a? User
        cat      = Category.new(params[:category])
        cat.user = @user
        if cat.save
          render :update do |page|
            page.insert_html :bottom, :category_list,
                             :partial => 'editable_category',
                             :locals  => { :cat => cat }
            page[:new_category_form].hide
            page[:new_category_link].show
          end and return
        end
      end
    end
    render :nothing => true
  end

end
