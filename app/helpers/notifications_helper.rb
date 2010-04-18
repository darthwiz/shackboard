module NotificationsHelper

  def link_to_notification(ntf)
    s = post_time(ntf.created_at) + ' - '
    case ntf.notifiable_type
    when 'Comment'
      s << link_to(cleanup(ntf.actor.username), ntf.actor)
      s << ' ha commentato'
      comment     = ntf.notifiable
      commentable = comment.commentable
      case commentable.class.to_s
      when 'BlogPost'
        post_link = link_to('messaggio nel blog', commentable)
        if commentable.user == @user
          s << ' il tuo ' + post_link
        else
          s << ' il ' + post_link + ' di ' + link_to(cleanup(commentable.user.username), commentable.user)
        end
      end
    end
    s
  end

  def link_to_unread_notifications(how_many)
    text = nil
    case how_many.to_i
    when 0
      text = "Non ci sono nuove notifiche"
    when 1
      text = "Hai una nuova notifica"
    else
      text = "Hai #{how_many} nuove notifiche"
    end
    link_to(text, notifications_path)
  end

end
