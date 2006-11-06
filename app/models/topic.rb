class Topic < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name table_name_prefix + "threads"
  set_primary_key "tid"
  belongs_to :forum, :foreign_key   => "fid", :dependent => :destroy,
                     :counter_cache => :threads
  has_many   :posts, :foreign_key   => "tid", :dependent => :destroy
  def container # {{{
    Forum.find(self.fid)
  end # }}}
  def name # {{{
    self.subject
  end # }}}
  def title # {{{
    self.subject
  end # }}}
  def total_posts # {{{
    self.replies + 1
  end # }}}
  def acl # {{{
    AclMapping.map(self) || self.container.acl
  end # }}}
  def user # {{{
    user = User.find_by_username(self.author)
    user = User.new unless user
    user
  end # }}}
def fix_counters # {{{
  self[:replies] = Topic.find(self.id).posts_count
  self.save
end # }}}
  def move_to(forum) # {{{
    raise ArgumentError, "argument is not a Forum" unless forum.is_a? Forum
    self.posts.each do |p|
      p.forum = forum
      p.save
    end
    self.forum = forum
    self.save
  end # }}}
end
