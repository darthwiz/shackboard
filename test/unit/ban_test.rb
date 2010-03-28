require 'test_helper'

# Extend the Time class so that we can offset the time that 'now'
# returns.  This should allow us to effectively time warp for functional
# tests that require limits per hour, what not.
class Time #:nodoc:
  class << self
    attr_accessor :testing_offset
    alias_method :real_now, :now
    def now
      real_now - testing_offset
    end
    alias_method :new, :now
  end
end
Time.testing_offset = 0

class BanTest < ActiveSupport::TestCase

  test "active_at scope" do
    all_of_june_2009       = bans(:all_of_june_2009)
    may_2006_until_forever = bans(:may_2006_until_forever)
    now                    = Time.parse('2007-04-01')
    assert(Ban.active_at(now).include?(may_2006_until_forever))
    assert(!Ban.active_at(now).include?(all_of_june_2009))
    now = Time.parse('2009-06-02')
    assert(Ban.active_at(now).include?(may_2006_until_forever))
    assert(Ban.active_at(now).include?(all_of_june_2009))
    now = Time.parse('2005-06-02')
    assert(!Ban.active_at(now).include?(may_2006_until_forever))
    assert(!Ban.active_at(now).include?(all_of_june_2009))
  end

  test "with_forum scope" do
    agora_ban = bans(:runner_agora_june_2007)
    agora     = forums(:agora)
    qdoa      = forums(:qdoa)
    other_ban = bans(:all_of_june_2009)
    assert(Ban.with_forum(agora).include?(agora_ban))
    assert(!Ban.with_forum(agora).include?(other_ban))
    assert(Ban.with_forums([ agora, qdoa ]).include?(agora_ban))
  end

  test "with_user scope" do
    agora_ban = bans(:runner_agora_june_2007)
    runner    = User.find_by_username('runner')
    other_ban = bans(:all_of_june_2009)
    assert(Ban.with_user(runner).include?(agora_ban))
    assert(!Ban.with_user(runner).include?(other_ban))
  end

  test "with_moderator scope" do
    agora_ban = bans(:runner_agora_june_2007)
    ark       = User.find_by_username('Ark Intruso')
    other_ban = bans(:all_of_june_2009)
    assert(Ban.with_moderator(ark).include?(agora_ban))
    assert(!Ban.with_moderator(ark).include?(other_ban))
  end

  test "basic ban" do
    runner = User.find_by_username('runner')
    agora  = forums(:agora)
    pretend_now_is(Time.parse('2007-05-02')) { assert(agora.can_post?(runner)) }
    pretend_now_is(Time.parse('2007-06-02')) do
      assert(!agora.can_post?(runner))
      assert(agora.banned?(runner))
      assert(!agora.can_edit?(runner))
      assert(!agora.can_moderate?(runner))
      assert(agora.can_read?(runner))
    end
    pretend_now_is(Time.parse('2007-07-02')) { assert(agora.can_post?(runner)) }
  end

  test "editing" do
    ban = bans(:runner_agora_june_2007)
    assert(ban.can_edit?(users(:ark_intruso)))
    assert(ban.can_edit?(users(:kaworu)))
    assert(ban.can_edit?(users(:wiz)))
    assert(!ban.can_edit?(users(:runner)))
  end

  test "sane limit" do
    ban            = Ban.new
    now            = Time.now
    ban.expires_at = now + 3.years
    ban.moderator  = users(:ark_intruso)
    ban.user       = users(:runner)
    ban.forum      = forums(:agora)
    ban.save!
    ban = Ban.find(ban.id)
    # looks like we have to round to 1-second resolution
    # assert the time difference is within 10 seconds, to prevent rounding
    # problems.
    assert(((now + 2.years).to_i - ban.expires_at.to_i).abs < 10)
  end

end
