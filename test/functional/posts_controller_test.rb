require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  fixtures :posts, :threads

  def test_missing_topics
    get(:show, { :id => 33538, :format => 'html' })
    assert_response :gone
  end

end
