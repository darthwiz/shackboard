class Smiley < ActiveRecord::Base
  set_table_name table_name_prefix + "smilies"
  set_inheritance_column "_type"
  belongs_to :user
  validates_format_of :url,  :with => %r{^http:\/\/[/.[:alnum:]_-]*\.(gif|jpg|png)$}
  validates_format_of :code, :with => /^:[[:alnum:]_-]+:/
  attr_accessor :parsed

  def Smiley.all(user=nil)
    if user.is_a? User
      conds = [ 'type = ? AND (user_id = 0 OR user_id = ?) AND code != ""', 'smiley', user.id ]
    else
      conds = [ 'type = ? AND user_id = 0 AND code != ""', 'smiley' ]
    end
    Smiley.find(:all, :conditions => conds, :order => 'user_id DESC')
  end

  def url
    base_url = "http://www.studentibicocca.it/portale/forum/images"
    url      = read_attribute(:url)
    url      = base_url + "/" + url unless url =~ /^http/
    url
  end

end
