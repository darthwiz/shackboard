class TopicController < ApplicationController
  def view # {{{
    ppp   = @opts[:ppp]
    start = params[:start].to_i
    start = 1 if (start == 0)
    # convert textual topic ids to numeric {{{
    tid = params[:id].to_i
    if (tid <= 0) then
      topic = Topic.find(
        :first,
        :conditions => ["subject LIKE ?", params[:id].to_s + "%"],
        :order => 'lastpost DESC'
      )
      if (topic.is_a? Topic) then
        tid = topic.id
      end
    end
    # }}}
    # try to get the requested topic or fail nicely {{{
    begin
      @topic = Topic.find(tid)
      fid    = @topic.fid
    rescue
      render :partial => "not_found" and return
    end
    # }}}
    # check access control once we have found the topic {{{
    unless @topic.acl.can_read?(@user)
      render :partial => "not_authorized" and return
    end
    # }}}
    # XXX ugly workaround to bad legacy data model {{{
    firstpost = Post.new
    @topic.attribute_names.each do |a|
      firstpost.send(a + '=', @topic.send(a)) if firstpost.respond_to?(a + '=')
    end
    if (start <= ppp) then
      offset = 0
      limit  = ppp - 1
    else
      offset = ((start - 1)/ppp)*ppp - 1
      limit  = ppp
    end
    # }}}
    conds  = ["tid = ? AND fid = ? AND deleted IS NULL", tid, fid]
    @posts = Post.find :all,
                       :conditions => conds,
                       :order      => 'dateline',
                       :limit      => limit,
                       :offset     => offset
    # XXX hack again {{{
    @posts.unshift(firstpost) if (offset == 0)
    # }}}
    if (offset == 0) then
      seq = 1
    else
      seq = offset + 2
    end
    @posts.each { |p| p.seq = seq; seq += 1 }
    @pageseq_opts = { :first      => 1,
                      :last       => @topic.replies + 1,
                      :ipp        => ppp,
                      :current    => start,
                      :controller => 'topic',
                      :action     => 'view',
                      :id         => tid }
  end # }}}
end
