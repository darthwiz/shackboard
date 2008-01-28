class SmileyController < ApplicationController
  def list
    uid      = @user.is_a?(User) ? @user.id : 0
    uid      = params[:id] ? params[:id] : uid
    uid      = uid.to_i # could be zero
    conds    = [ 'type = ? AND user_id = ?', 'smiley', uid ]
    order    = 'user_id DESC, id'
    @smileys = Smiley.find(:all, :conditions => conds, :order => order)
  end

  def edit_in_place
    if request.xml_http_request?
      sm = Smiley.find(params[:id])
      render :partial => 'smiley_edit', :locals => { :sm => sm }
    end
  end

  def create
    if @user.is_a? User
      sm = Smiley.new
      sm.user = @user
      sm.type = 'smiley'
      sm.code = params[:code]
      sm.url  = params[:url]
      sm.save
      redirect_to(:action => 'list') and return
    end
  end

  def edit # for real
    if(request.xml_http_request? && @user.is_a?(User))
      url     = params[:url]
      code    = params[:code]
      id      = params[:id].to_i
      sm      = Smiley.find_by_id_and_user_id(id, @user.id)
      sm.code = code
      sm.url  = url
      sm.save!
      sm = Smiley.find(id)
      render :partial => 'smiley', :locals => { :sm => sm }
    end
  end

  def delete
    if(request.xml_http_request? && @user.is_a?(User))
      id = params[:id].to_i
      sm = Smiley.find(id)
      if sm.user_id == @user.id
        sm.destroy
      end
      render :nothing => true
    end
  end

  def css
    headers["Content-Type"] = 'text/css; charset = utf-8'
    @theme_name             = params[:id].sub(/\.css$/, "")
    render :partial => 'css'
  end
end
