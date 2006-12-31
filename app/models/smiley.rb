class Smiley < ActiveRecord::Base
  set_table_name table_name_prefix + "smilies"
  set_inheritance_column "_type"
  Base_url = "http://www.studentibicocca.it/portale/forum/images"
  def Smiley.all # {{{
    Smiley.find_all_by_type("smiley")
  end # }}}
  def url # {{{
    Base_url + "/" + read_attribute(:url)
  end # }}}
end
