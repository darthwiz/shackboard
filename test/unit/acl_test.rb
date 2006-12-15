require File.dirname(__FILE__) + '/../test_helper'
require 'acl'
class AclTest < Test::Unit::TestCase
  fixtures :acls, :acl_mappings, :forums, :members, :groups, :group_memberships
  def test_reality_check # {{{
    assert Acl.find(1).can_read?(["User", :any])
    assert !Acl.find(84).can_read?(["User", :any])
  end # }}}
  def test_can_do? # {{{
    assert Acl.find(1).can_read?(["User", :any])
    assert Acl.find(84).can_read?(["User", 182])
    assert !Acl.find(84).can_read?(["User", :any])
    assert !Acl.find(1).can_walk_on_water?(["User", 182])
  end # }}}
  def test_forum_acl # {{{
    bin    = Forum.find(93)
    runner = User.find_by_username("runner")
    assert bin.acl.can_read?(runner)
  end # }}}
  def test_permission_assignment # {{{
    mod_agora = Group.find_by_name('mod_agora')
    runner    = User.find_by_username("runner")
    wiz       = User.find_by_username('wiz')
    assert !mod_agora.acl.can_edit?(wiz)
    assert !mod_agora.acl.can_edit?(runner)
    mod_agora.acl.can_edit(wiz)
    assert mod_agora.acl.can_edit?(wiz)
    assert !mod_agora.acl.can_edit?(runner)
    mod_agora.acl.can_edit(Group.find_by_name("mod_agora"))
    assert mod_agora.acl.can_edit?(wiz)
    assert mod_agora.acl.can_edit?(runner)
    mod_agora.acl.cant_edit(['User', :any])
    assert !mod_agora.acl.can_edit?(wiz)
  end # }}}
  def test_permission_removal # {{{
    mod_agora = Group.find_by_name('mod_agora')
    runner    = User.find_by_username("runner")
    wiz       = User.find_by_username('wiz')
    assert !mod_agora.acl.can_edit?(wiz)
    assert !mod_agora.acl.can_edit?(runner)
    mod_agora.acl.remove_cant_edit(["User", :any])
    assert mod_agora.acl.can_edit?(wiz)
    assert mod_agora.acl.can_edit?(runner)
  end # }}}
end
