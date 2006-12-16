require File.dirname(__FILE__) + '/../test_helper'
require 'group'
class GroupTest < Test::Unit::TestCase
  fixtures :groups, :group_memberships, :members
  def test_reality_check # {{{
    assert_equal("mod_agora", Group.find(1).name)
  end # }}}
  def test_include? # {{{
    ark    = User.find_by_username("Ark Intruso")
    kaworu = User.find_by_username("Kaworu")
    runner = User.find_by_username("runner")
    assert Group.include?(['Group', 'mod_agora'], ark)
    assert Group.include?(['Group', 'mod_agora'], kaworu)
    assert Group.include?(['Group', 'mod_agora'], runner)
  end # }}}
  def test_membership # {{{
    usernames = []
    Group.find(1).users.each { |u| usernames << u.username }
    assert_equal(["Ark Intruso", "Kaworu", "runner"], usernames)
  end # }}}
end
