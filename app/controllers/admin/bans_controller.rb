class Admin::BansController < Admin::ApplicationController
  before_filter :authenticate
  layout 'forum'
  
  def index
    @active_bans = Ban.active_at(Time.now).find(:all, :include => [ :user, :moderator, :forum ])
    @page_title  = "Espulsioni"
    @location    = [ :admin, :bans ]
  end

  def new
    if @user.is_mod?
      @forums   = @user.is_supermod? ? Forum.flattened_list : @user.moderates
      @ban      = Ban.new(:moderator => @user)
      @days     = 1
      @hours    = 0
      @location = [ :admin, @ban ]
    else
      flash[:warning] = "Non sei autorizzato ad espellere utenti."
      redirect_to admin_bans_path
    end
  end

  def create
    @forum = Forum.find(params[:ban][:forum])
    if @forum.can_moderate?(@user)
      user = User.find_by_username(params[:username])
      if user.nil?
        flash[:warning] = "L'utente '#{params[:username]}' non è stato trovato."
        redirect_to :back and return
      end
      @ban            = Ban.new(:moderator => @user, :user => user, :forum => @forum)
      @ban.reason     = params[:ban][:reason]
      @ban.expires_at = Time.now + params[:days].to_i.days + params[:hours].to_i.hours
      @ban.save!
      flash[:success] = "L'utente #{user.username} è stato espulso correttamente."
    else
      flash[:warning] = "Non sei autorizzato ad espellere utenti da questo forum."
    end
    redirect_to admin_bans_path
  end

  def edit
    @ban = Ban.find(params[:id], :include => [ :user, :moderator, :forum ])
    if @ban.can_edit?(@user)
      @page_title      = "Espulsione di #{@ban.user.username}"
      @location        = [ :admin, @ban ]
      @remaining_days  = ((@ban.expires_at - Time.now) / 1.day).to_i
      @remaining_hours = ((@ban.expires_at - Time.now) % 1.day / 1.hour).round
    else
      flash[:warning] = "Non sei autorizzato a modificare questa espulsione."
      redirect_to admin_bans_path
    end
  end

  def update
    @ban = Ban.find(params[:id], :include => [ :user, :moderator, :forum ])
    if @ban.can_edit?(@user)
      @ban.reason     = params[:ban][:reason]
      @ban.expires_at = Time.now + [0, params[:days].to_i * 1.day].max + [0, params[:hours].to_i * 1.hour].max
      @ban.save!
      redirect_to admin_bans_path
    else
      flash[:warning] = "Non sei autorizzato a modificare questa espulsione."
      redirect_to admin_bans_path
    end
  end

end
