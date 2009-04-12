class Notifier < ActionMailer::Base
  def signup_notification(recipient, username, password)
    recipients recipient
    subject    "La tua password per StudentiBicocca.it"
    from       "StudentiBicocca.it <portale.studentibicocca@gmail.com>"
    reply_to   "asb@studentibicocca.it"
    body       :username => username, :password => password
  end
end
