require File.dirname(__FILE__) + '/../test_helper'
require 'forum'
class ForumTest < ActiveSupport::TestCase
  fixtures :forums

  test "null field bugs" do
    simplest = forums(:simplest)
    assert(simplest.can_read?(nil))
    assert_nil(simplest.last_post)
  end

end
