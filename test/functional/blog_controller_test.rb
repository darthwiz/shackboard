require File.dirname(__FILE__) + '/../test_helper'
require 'blog_controller'

class BlogController
  def rescue_action(e)
    raise e
  end
end

class BlogControllerTest < Test::Unit::TestCase
  fixtures :settings

  def setup
    @controller = BlogController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_list
    get :list, { :username => 'wiz' }
    assert_response :success
  end
end
