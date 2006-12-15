require File.dirname(__FILE__) + '/../test_helper'
require 'group'
class GroupTest < Test::Unit::TestCase
  fixtures :groups, :group_memberships, :members
  def test_reality_check # {{{
    assert_equal("mod_agora", Group.find(1).name)
  end # }}}
  def test_include? # {{{
    assert Group.include?("mod_agora", User.find_by_username("Ark Intruso"))
    assert Group.include?("mod_agora", User.find_by_username("Kaworu"))
    assert Group.include?("mod_agora", User.find_by_username("runner"))
  end # }}}
  def test_membership # {{{
    usernames = []
    Group.find(1).users.each { |u| usernames << u.username }
    assert_equal(["Ark Intruso", "Kaworu", "runner"], usernames)
  end # }}}
end
