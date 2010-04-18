class CommentObserver < ActiveRecord::Observer

  def after_create(comment)
    ntf = Notification.new(
      :actor      => comment.user,
      :recipient  => comment.commentable.user,
      :notifiable => comment,
      :kind       => 'new'
    )
    ntf.save
  end

end
