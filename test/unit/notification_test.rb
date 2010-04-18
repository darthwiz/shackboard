require 'test_helper'

class NotificationTest < ActiveSupport::TestCase

  test "new blog post notification" do
    post    = blog_posts(:wiz_1)
    ark     = users(:ark)
    wiz     = users(:wiz)
    comment = Comment.new(:user => ark, :text => 'cool', :commentable => post, :ip_address => '1.2.3.4')
    comment.save
    ntf = Notification.find(:last)
    assert_equal(ark, ntf.actor)
    assert_equal(wiz, ntf.recipient)
    assert_equal('new', ntf.kind)
    assert_equal(comment, ntf.notifiable)
  end

end
