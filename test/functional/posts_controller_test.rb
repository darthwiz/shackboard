require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  fixtures :posts, :threads

  def dont_test_missing_topics # FIXME
    get(:show, { :id => 33538, :format => 'html' })
    assert_response :gone
  end

end
