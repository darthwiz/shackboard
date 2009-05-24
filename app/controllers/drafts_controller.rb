class DraftsController < ApplicationController
  before_filter :authenticate
  layout 'forum'
  
  def index
    redirect_to root_path and return unless @user.is_a? User
    ppp           = @opts[:ppp]
    start         = params[:start].to_i
    start         = 1 if (start <= 0)
    offset        = ((start - 1)/ppp)*ppp
    limit         = ppp
    @drafts       = Draft.find_paged_for(@user, offset, limit)
    @drafts_count = Draft.count_unsent_for(@user)
    @pageseq_opts = { 
      :controller  => :draft,
      :action      => :index,
      :last        => @drafts_count,
      :current     => start,
      :ipp         => ppp,
      :extra_links => [ :first, :forward, :back, :last ]
    }
    @location = @drafts
  end

  def destroy
    @draft = Draft.secure_find(params[:id], @user)
    @draft.destroy
    render :nothing => true
  end

end
