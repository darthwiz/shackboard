class Smiley < ActiveRecord::Base
  set_table_name table_name_prefix + "smilies"
  set_inheritance_column "_type"
  belongs_to :user
  validates_format_of :url,  :with => %r{^http:\/\/[/.[:alnum:]_-]*\.(gif|jpg|png)$}
  validates_format_of :code, :with => /^:[[:alnum:]_-]+:/
  def Smiley.all(user=nil)
    if user.is_a? User
      conds = [ 'type = ? AND (user_id = 0 OR user_id = ?)', 'smiley', user.id ]
    else
      conds = [ 'type = ? AND user_id = 0', 'smiley' ]
    end
    Smiley.find(:all, :conditions => conds)
  end
  def url
    base_url = "http://www.studentibicocca.it/portale/forum/images"
    url      = read_attribute(:url)
    url      = base_url + "/" + url unless url =~ /^http/
    url
  end
end
