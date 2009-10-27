require File.dirname(__FILE__) + '/../test_helper'
require 'user'
class UserTest < ActiveSupport::TestCase
  fixtures :users

  def test_reality_check
    assert_equal(User.find_by_username("wiz").id, 182)
  end

end
