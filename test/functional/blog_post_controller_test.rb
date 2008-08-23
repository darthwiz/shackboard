require File.dirname(__FILE__) + '/../test_helper'
require 'blog_post_controller'

class BlogPostController
  def rescue_action(e)
    raise e
  end
end

class BlogPostControllerTest < Test::Unit::TestCase
  fixtures :settings

  def setup
    @controller = BlogPostController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_view_comments
    get :view_comments
    assert_response :success
  end
end
