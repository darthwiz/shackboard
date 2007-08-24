require File.dirname(__FILE__) + '/../test_helper'
require 'draft'
class DraftTest < Test::Unit::TestCase
  fixtures :members, :forums
  def test_life_cycle # {{{
    wiz            = User.find_by_username('wiz')
    d              = Draft.new
    f              = Forum.find(27)
    assert !d.save
    d.user         = wiz
    assert !d.save
    d.object       = Post.new
    assert !d.save
    d.object.forum = f
    d.object.tid   = 27134
    assert !d.save
    d.timestamp    = Time.now.to_i
    assert d.save
    d              = Draft.find(d.id)
    assert_instance_of(Draft, d)
    assert_equal('Post', d.object_type)
    assert_instance_of(Post, d.object)
    assert_equal(wiz, d.user)
    assert_equal(27, d.object.fid)
    assert_equal(27134, d.object.tid)
    assert d.destroy
  end # }}}
end
