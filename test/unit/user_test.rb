require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "banned_from_forum_at_time scope" do
    runner    = users(:runner)
    agora     = forums(:agora)
    may_2007  = Time.parse('2007-05-01')
    june_2007 = Time.parse('2007-06-02')
    assert(!User.banned_from_forum_at_time(agora, may_2007).include?(runner))
    assert(User.banned_from_forum_at_time(agora, june_2007).include?(runner))
  end

end
