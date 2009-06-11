require File.dirname(__FILE__) + '/../test_helper'
require 'group_membership'
class GroupMembershipTest < ActiveSupport::TestCase
  fixtures :group_memberships
  def test_reality_check # {{{
    assert_equal("Ark Intruso", GroupMembership.find(1).username)
    assert_equal("Kaworu", GroupMembership.find(2).username)
    assert_equal("runner", GroupMembership.find(3).username)
  end # }}}
end
