class Post < ActiveRecord::Base
  set_table_name table_name_prefix + "posts"
  set_primary_key "pid"
  belongs_to :topic, :foreign_key => "tid"
  belongs_to :forum, :foreign_key => "fid"
  attr_accessor :seq
  def container # {{{
    Topic.find(self.tid)
  end # }}}
  def acl # {{{
    acl = AclMapping.map(self) || self.container.acl
  end # }}}
end
