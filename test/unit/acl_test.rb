require File.dirname(__FILE__) + '/../test_helper'
require 'acl'
class AclTest < Test::Unit::TestCase
  fixtures :members, :groups, :group_memberships, :acls, :acl_mappings
  def test_permission_assignment
    runner = User.find_by_username("runner")
    wiz    = User.find_by_username('wiz')
    tex    = User.find_by_username('tex1803')
    acl    = Acl.new

    # with a new ACL, every permission is negated for everyone
    assert !acl.can_edit?(wiz)
    assert !acl.can_edit?(runner)

    # adding a new action for a single user: it should grant the permission for
    # him only, and for that action only
    assert_equal(Acl, acl.can_edit(wiz).class)
    assert acl.can_edit?(wiz)     # this is what we intended
    assert !acl.can_edit?(runner) # same action, different user should fail
    assert !acl.can_delete?(wiz)  # same user, different action should fail

    # test with group ownership
    assert_equal(Acl, acl.can_edit(Group.find_by_name("mod_agora")).class)
    assert acl.can_edit?(wiz)    # same user as before should still pass
    assert acl.can_edit?(runner) # user in the group should pass
    assert !acl.can_edit?(tex)   # user not in group should fail

    # permission negation
    assert_equal(Acl, acl.cant_edit(['User', :any]).class) # everything should
                                                           # fail from now on
    assert !acl.can_edit?(wiz)    # single user should fail
    assert !acl.can_edit?(runner) # user in a group should fail

    # test with authenticated users
    assert !acl.can_read?(wiz)
    assert !acl.can_read?(nil)
    assert acl.can_read(['User', :authenticated])
    assert acl.can_read?(wiz)
    assert !acl.can_read?(nil)
  end

  def test_permission_removal
    wiz = User.find_by_username('wiz')
    acl = Acl.new
    assert !acl.can_test?(wiz) # undefined action should fail
    acl.can_test(wiz)
    assert acl.can_test?(wiz)  # should now pass
    acl.cant_test(wiz)
    assert !acl.can_test?(wiz) # negated action should fail
    acl.remove_cant_test(wiz)
    assert acl.can_test?(wiz)  # should now pass
    acl.remove_can_test(wiz)
    assert !acl.can_test?(wiz) # should now fail
  end

  def test_object_attachment_and_persistence_step_1
    # NOTE this test depends on Group implementation
    runner    = User.find_by_username("runner")
    wiz       = User.find_by_username('wiz')
    tex       = User.find_by_username('tex1803')
    mod_agora = Group.find_by_name("mod_agora")
    mod_qdoa  = Group.find_by_name("mod_qdoa")

    # groups attach themselves a new ACL as soon as it is referenced, but
    # saving it is the caller's responsibility. Also, if a new ACL is attached,
    # it is persistently mapped to the group as it is saved.

    # ACLs are (supposed to be) fresh, so the following tests should all fail
    assert !mod_agora.can_edit?(wiz)
    assert !mod_agora.can_edit?(runner)
    assert !mod_agora.can_edit?(tex)
    assert !mod_qdoa.can_edit?(wiz)
    assert !mod_qdoa.can_edit?(runner)
    assert !mod_qdoa.can_edit?(tex)

    # let's add some permissions
    mod_agora.can_edit(mod_agora)
    mod_agora.can_edit(tex)
    mod_qdoa.can_edit(wiz)

    # and check that they are as intended
    assert !mod_agora.can_edit?(wiz)
    assert mod_agora.can_edit?(runner)
    assert mod_agora.can_edit?(tex)
    assert mod_qdoa.can_edit?(wiz)
    assert !mod_qdoa.can_edit?(runner)
    assert !mod_qdoa.can_edit?(tex)

    # now we persist only one of the ACLs, the other one will be lost as soon
    # as it is no longer referenced
    mod_agora.acl_save
  #end

  #def test_object_attachment_and_persistence_step_2
    # XXX test data is *not* supposed to persist, wtf?
    runner    = User.find_by_username("runner")
    wiz       = User.find_by_username('wiz')
    tex       = User.find_by_username('tex1803')
    mod_agora = Group.find_by_name("mod_agora")
    mod_qdoa  = Group.find_by_name("mod_qdoa")

    # from the previous test we expect that only mod_agora's ACL has been saved
    assert !mod_agora.can_edit?(wiz)
    assert mod_agora.can_edit?(runner)
    assert mod_agora.can_edit?(tex)
    # so these should all fail
    assert !mod_qdoa.can_edit?(wiz)
    assert !mod_qdoa.can_edit?(runner)
    assert !mod_qdoa.can_edit?(tex)
  end

end
