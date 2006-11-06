class Post < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name table_name_prefix + "posts"
  set_primary_key "pid"
  belongs_to :topic, :foreign_key   => "tid", :dependent => :destroy,
                     :counter_cache => :replies
  belongs_to :forum, :foreign_key   => "fid", :dependent => :destroy,
                     :counter_cache => :posts
  #belongs_to :user
  attr_accessor :seq
  def container # {{{
    Topic.find(self.tid)
  end # }}}
  def acl # {{{
    acl = AclMapping.map(self) || self.container.acl
  end # }}}
  def user # {{{
    user = User.find_by_username(self.author)
    user = User.new unless user
    user
  end # }}}
end
