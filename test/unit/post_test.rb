require File.dirname(__FILE__) + '/../test_helper'

class PostTest < ActiveSupport::TestCase
  #fixtures :posts

  test "do not show posts from anonymized users in search results" do
    assert(!Post.with_user(users(:wiz)).empty?)
    assert(Post.with_user(users(:insania)).empty?)
  end

end
