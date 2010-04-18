class CommentObserver < ActiveRecord::Observer

  def after_create(comment)
    commentable = comment.commentable
    recipients  = commentable.comments.find(:all, :select => :user_id, :include => :user).collect(&:user)
    recipients << commentable.user
    recipients.uniq.reject { |i| i == comment.user }.each do |user|
      Notification.new(
        :actor      => comment.user,
        :recipient  => user,
        :notifiable => comment,
        :kind       => 'new'
      ).save
    end
  end

end
