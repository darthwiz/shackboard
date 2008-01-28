class Smiley < ActiveRecord::Base
  set_table_name table_name_prefix + "smilies"
  set_inheritance_column "_type"
  belongs_to :user
  validates_format_of :url,  :with => %r{^http:\/\/[/.[:alnum:]_-]*\.(gif|jpg|png)$}
  validates_format_of :code, :with => /^:[[:alnum:]_-]+:/
  def Smiley.all
    Smiley.find_all_by_type_and_user_id("smiley", 0)
  end
  def url
    base_url = "http://www.studentibicocca.it/portale/forum/images"
    url      = read_attribute(:url)
    url      = base_url + "/" + url unless url =~ /^http/
    url
  end
end
