class Admin::StaffController < Admin::ApplicationController
  before_filter :authenticate
  layout 'forum'

  def show
    @forums     = Forum.find(:all, :conditions => 'fup = 0', :order => 'displayorder')
    @admins     = User.admins
    @supermods  = User.supermods
    @all_mods   = User.find_all_by_username(Forum.all.collect { |f| f.moderator.split(/,\s/) }.flatten.uniq).sort { |a, b| a.username.downcase <=> b.username.downcase }
    @page_title = "Staff"
    @location   = [ :admin, :staff ]
  end

  def update
    if @user.is_adm?
      adm_string = params[:administrators].to_s
      old_adms   = User.admins
      new_adms   = User.find_all_by_username(adm_string.split(/,\s*/))
      if new_adms.empty?
        flash[:error] = "È richiesta la presenza di almeno un amministratore."
        redirect_to admin_staff_path and return
      else
        old_adms.each do |u|
          unless new_adms.include?(u)
            u.status = 'Member'
            u.save_without_validation
          end
        end
        new_adms.each do |u|
          u.status = 'Administrator'
          u.save_without_validation
        end
      end
    end
    if @user.is_supermod?
      supermod_string = params[:supermods].to_s
      old_supermods   = User.supermods
      new_supermods   = User.find_all_by_username(supermod_string.split(/,\s*/))
      current_adms    = User.admins
      old_supermods.each do |u|
        unless new_supermods.include?(u) || current_adms.include?(u)
          u.status = 'Member'
          u.save_without_validation
        end
      end
      new_supermods.each do |u|
        u.status = 'Super Moderator'
        u.save_without_validation
      end
    end
    params[:moderators].each_pair do |fid, mods|
      forum           = Forum.find(fid)
      new_mods        = User.find_all_by_username(mods.split(/,\s*/)).collect(&:username).sort.join(', ')
      forum.moderator = new_mods
      forum.save!
    end
    flash[:success] = "Le modifiche sono state salvate correttamente."
    redirect_to :back
  end

end
