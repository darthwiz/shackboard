require 'test_helper'

class AppConfigurationTest < ActiveSupport::TestCase

  test "ensure a minimal configuration" do
    assert(Conf.posts_per_page.to_i > 0)
    assert(Conf.topics_per_page.to_i > 0)
    assert_not_nil(Conf.default_theme)
    assert_not_nil(Conf.default_page_title)
    assert_not_nil(Conf.email_notifier['subscription_subject'])
    assert_not_nil(Conf.email_notifier['mail_from'])
    assert_not_nil(Conf.email_notifier['reply_to'])
  end

end
