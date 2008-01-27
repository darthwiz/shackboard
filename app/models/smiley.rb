class Smiley < ActiveRecord::Base
  set_table_name table_name_prefix + "smilies"
  set_inheritance_column "_type"
  belongs_to :user
  Base_url = "http://www.studentibicocca.it/portale/forum/images"
  def Smiley.all
    Smiley.find_all_by_type_and_user_id("smiley", 0)
  end
  def url
    url = read_attribute(:url)
    url = Base_url + "/" + url unless url =~ /^http/
    url
  end
end
