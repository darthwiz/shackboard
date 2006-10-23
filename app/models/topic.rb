class Topic < ActiveRecord::Base
  set_table_name table_name_prefix + "threads"
  set_primary_key "tid"
  belongs_to :forum, :foreign_key => "fid"
  has_many :posts
  def container # {{{
    Forum.find(self.fid)
  end # }}}
  def name # {{{
    self.subject
  end # }}}
  def title # {{{
    self.subject
  end # }}}
  def posts # {{{
    self.replies + 1
  end # }}}
  def acl # {{{
    AclMapping.map(self) || self.container.acl
  end # }}}
end
