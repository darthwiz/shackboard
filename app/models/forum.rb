class Forum < ActiveRecord::Base
  set_table_name table_name_prefix + "forums"
  set_inheritance_column "_type"
  set_primary_key "fid"
  has_many :topics
  def container # {{{
    begin
      Forum.find(self.fup)
    rescue
      return nil
    end
  end # }}}
end
