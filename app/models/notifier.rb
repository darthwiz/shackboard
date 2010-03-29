class Notifier < ActionMailer::Base

  def signup_notification(recipient, username, password)
    recipients recipient
    subject    Conf.email_notifier['subject']
    from       Conf.email_notifier['mail_from']
    reply_to   Conf.email_notifier['reply_to']
    body       :username => username, :password => password
  end

end
