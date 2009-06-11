require File.dirname(__FILE__) + '/../test_helper'
require 'forum'
class ForumTest < ActiveSupport::TestCase
  fixtures :forums

  def test_reality_check 
    assert_equal("<b>Agorà</b>", Forum.find(27).name)
  end 

end
