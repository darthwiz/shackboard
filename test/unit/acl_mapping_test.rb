require File.dirname(__FILE__) + '/../test_helper'
require 'acl_mapping'
class AclMappingTest < ActiveSupport::TestCase
  fixtures :acl_mappings, :forums
  def test_reality_check # {{{
    assert_equal(93, AclMapping.find(84).associated_object.id)
  end # }}}
end
