class SmileysController < ApplicationController

  def index
    uid      = params[:user_id].to_i || 0
    conds    = [ 'type = ? AND user_id = ?', 'smiley', uid ]
    order    = 'user_id DESC, id'
    @smileys = Smiley.find(:all, :conditions => conds, :order => order)
    respond_to do |format|
      format.js { render :partial => 'editable_index' }
    end
  end

  def edit
    @smiley = Smiley.find(params[:id])
    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace domid(@smiley), :inline => '<%=smiley_editor(@smiley)%>'
        end
      end
    end
  end

  def create
  end

  def update
    @smiley = Smiley.find(params[:id])
    @smiley.update_attributes(params[:smiley]) if @smiley.can_edit?(@user)
    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace domid(@smiley), :inline => '<%=editable_smiley(@smiley)%>'
        end
      end
    end
  end

  def destroy
    @smiley = Smiley.find(params[:id])
    @smiley.destroy if @smiley.can_delete?(@user)
    respond_to do |format|
      format.js do
        render :update do |page|
          page.remove domid(@smiley)
        end
      end
    end
  end

end
