class SearchController < ApplicationController

  layout 'forum'

  def search
    @query_string  = params[:q].to_s
    @username      = params[:username]
    @time          = params[:time] || 'week'
    @query_tags    = params[:tags]
    ppp            = @opts[:ppp]
    start          = params[:start].to_i - 1
    start          = 0 if (start <= 0)
    rstart         = (start/ppp)*ppp
    rend           = rstart + ppp - 1
    @range         = rstart..rend
    @location      = :search_results
    prepare_posts_by_matching_text if @query_tags.blank?
    prepare_topics_by_matching_tags
    @page_seq_opts = { :last        => [ @posts_count, @tagged_topics_count ].max,
                       :ipp         => ppp,
                       :current     => start + 1,
                       :get_parms   => [ :q, :time, :username ],
                       :extra_links => [ :first, :forward, :back, :last ] }
  end

  private

  def prepare_posts_by_matching_text
    time           = { 'all' => 0, 'year' => 1.year.ago, 'month' => 1.month.ago, 'week' => 1.week.ago }
    after          = time[@time]
    user           = User.find_by_username(@username)
    qs             = QueryString.new(@query_string).to_mysql
    finder         = Post.public_only.after_time(after)
    finder         = finder.with_matching_text(qs) unless @query_string.blank?
    finder         = finder.with_user(user) unless @username.blank?
    @posts_count   = finder.count
    @posts_by_text = finder.range(@range).including_user.including_topic.ordered_by_time_desc
  end

  def prepare_topics_by_matching_tags
    if @query_tags.blank?
      @query_tags = @query_string.split(/\s+/).reject(&:blank?).join(',').strip unless @query_string =~ /,/ 
    else
      clean_tags = @query_tags.split(/\//).collect(&:slugify).reject(&:blank?).sort.uniq
      redirect_to :tags => clean_tags and return unless @query_tags == clean_tags.join('/')
      @query_tags = clean_tags
      @page_title = @query_tags.join(', ') + ' - ' + Conf.default_page_title
    end
    finder               = Topic.including_forum.including_tags.tagged_with(@query_tags)
    @tagged_topics_count = finder.count
    @topics_by_tags      = finder.range(@range).find(:all, :order => 'lastpost DESC')
  end

end
