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
end
