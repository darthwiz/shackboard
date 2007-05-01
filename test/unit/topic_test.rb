require File.dirname(__FILE__) + '/../test_helper'
require 'topic'
class TopicTest < Test::Unit::TestCase
  fixtures :forums
  fixtures :threads
  def test_reality_check # {{{
    assert_equal 27, Topic.find(49076).fid
  end # }}}
  def test_can_post? # {{{
    t = Topic.find(49076)
    assert !t.can_post?(['User', nil])
    assert !t.can_post?(nil)
    assert t.can_post?(['User', 182])
  end # }}}
end
