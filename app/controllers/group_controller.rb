class GroupController < ApplicationController
  def list
    @groups = Group.find :all, :order => 'name'
  end

  def add_user
    group = Group.find(params[:id])
    render :nothing => true unless group && can_edit?(group)
    if request.xml_http_request?
      user = User.find_by_username(params[:username])
      if user
        if Group.associate!(group, user)
          @updated_group = group
          @added_user    = user
          render :action => 'ajax_add_user'
        end
      else
        render :nothing => true
      end
    end
  end

  def remove_user
    group  = Group.find(params[:id])
    userid = params[:user]
    render :nothing => true unless userid && can_edit?(group)
    if request.xml_http_request?
      group.remove!(['User', userid])
      if GroupMembership.find_by_group_id_and_user_id(group.id, userid).nil?
        render :action => 'ajax_remove_user'
      end
    end
  end

  def add_group
    gname = params[:groupname]
    render :nothing => true unless is_adm?
    if request.xml_http_request?
      g      = Group.new
      g.name = gname
      if g.save
        @added_group = g
        render :action => 'ajax_add_group' and return
      else
        render :nothing => true and return
      end
    end
    render :nothing => true
  end

  def delete_group
    render :nothing => true and return unless is_adm?
    group = Group.find(params[:id])
    if group.users_count == 0
      group.destroy
      render :action => 'ajax_delete_group' and return
    end
    render :nothing => true
  end

  def css
    headers["Content-Type"] = 'text/css; charset = utf-8'
    @theme_name             = params[:id].sub(/\.css$/, "")
    render :partial => 'css'
  end

  private
  def is_adm?(user=@user)
    Group.include?(['Group', GLOBAL_ADM_GROUP], user)
  end

  def can_edit?(group, user=@user)
    group.can_edit?(user) or is_adm?(user)
  end
end
