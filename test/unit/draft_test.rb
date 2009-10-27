require File.dirname(__FILE__) + '/../test_helper'
require 'draft'
class DraftTest < ActiveSupport::TestCase
  fixtures :users, :forums
  def test_life_cycle
    wiz = User.find_by_username('wiz')
    d   = Draft.new
    f   = Forum.find(27)
    assert !d.save
    d.user = wiz
    assert !d.save
    d.object = Post.new
    d.object.forum = f
    d.object.tid   = 27134
    d.object_type  = d.object.class.to_s
    assert d.save!
    d = Draft.find(d.id)
    assert_instance_of(Draft, d)
    assert_equal('Post', d.object_type)
    assert_instance_of(Post, d.object)
    assert_equal(wiz, d.user)
    assert_equal(27, d.object.fid)
    assert_equal(27134, d.object.tid)
    assert d.destroy
  end
end
