require File.dirname(__FILE__) + '/../test_helper'
require 'group'
class GroupTest < ActiveSupport::TestCase
  fixtures :groups, :group_memberships, :members
  def test_reality_check # {{{
    assert_equal("mod_agora", Group.find(1).name)
  end # }}}
  def test_group_include? # {{{
    ark    = User.find_by_username("Ark Intruso")
    kaworu = User.find_by_username("Kaworu")
    runner = User.find_by_username("runner")
    assert Group.include?(['Group', 'mod_agora'], ark)
    assert Group.include?(['Group', 'mod_agora'], kaworu)
    assert Group.include?(['Group', 'mod_agora'], runner)
  end # }}}
  def test_membership # {{{
    ark    = User.find_by_username("Ark Intruso")
    kaworu = User.find_by_username("Kaworu")
    runner = User.find_by_username("runner")
    agora  = Group.find(1)
    assert agora.users.include?(ark)
    assert agora.users.include?(kaworu)
    assert agora.users.include?(runner)
  end # }}}
  def test_creation # {{{
    g1 = Group.new
    g2 = Group.new
    g1.name = "test"
    g2.name = "test"
    assert g1.save  # this is ok
    assert !g2.save # this is not: name is not unique
    assert Group.find_by_name("test")
    assert Group.find_by_name("test").destroy
  end # }}}
  def test_association # {{{
    assert wiz = User.find_by_username("wiz")
    assert Group.new { |g| g.name = "test" }.save
    assert g = Group.find_by_name("test")
    assert g.associate!(wiz)  # first flavor
    assert !g.associate!(wiz) # false if identical association
    assert !g.associate!(['User', wiz.id]) # second flavor
    assert g.destroy
    assert GroupMembership.find_all_by_group_id(g.id).empty?
    assert g.users.empty?
  end # }}}
  def test_removal # {{{
    wiz = User.find_by_username("wiz")
    assert Group.new { |g| g.name = "test" }.save
    assert g = Group.find_by_name("test")
    assert_equal(Group, g.class)
    assert_equal(GroupMembership, g.associate!(wiz).class)
    assert_equal(GroupMembership, g.remove!(wiz).class)
    assert !g.remove!(wiz)
    assert_equal(GroupMembership, g.associate!(wiz).class)
    assert_equal(GroupMembership, g.remove!(['User', wiz.id]).class)
    assert g.users.empty?
    assert g.destroy
  end # }}}
end
