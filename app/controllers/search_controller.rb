class SearchController < ApplicationController

  layout 'forum'

  def search
    @query_string  = params[:q].to_s
    @username      = params[:username]
    @time          = params[:time] || 'week'
    prepare_posts_by_matching_text
  end

  private

  def prepare_posts_by_matching_text
    time           = { 'all' => 0, 'year' => 1.year.ago, 'month' => 1.month.ago, 'week' => 1.week.ago }
    after          = time[@time]
    user           = User.find_by_username(@username)
    qs             = QueryString.new(@query_string).to_mysql
    ppp            = @opts[:ppp]
    start          = params[:start].to_i - 1
    start          = 0 if (start <= 0)
    rstart         = (start/ppp)*ppp
    rend           = rstart + ppp - 1
    finder         = Post.public_only.after_time(after)
    finder         = finder.with_matching_text(qs) unless @query_string.blank?
    finder         = finder.with_user(user) unless @username.blank?
    @posts_count   = finder.count
    @range         = rstart..rend
    @posts         = finder.range(@range).including_user.including_topic.ordered_by_time_desc
    @location      = :search_results
    @page_seq_opts = { :last        => @posts_count,
                       :ipp         => ppp,
                       :current     => start + 1,
                       :get_parms   => [ :q, :time, :username ],
                       :extra_links => [ :first, :forward, :back, :last ] }
  end

end
