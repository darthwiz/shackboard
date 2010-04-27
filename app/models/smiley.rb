class Smiley < ActiveRecord::Base
  set_table_name table_name_prefix + "smilies"
  set_inheritance_column "_type"
  belongs_to :user
  validates_format_of :url,  :with => %r{^http:\/\/[/.[:alnum:]_-]*\.(gif|jpg|png)$}
  validates_format_of :code, :with => /^:[[:alnum:]_-]+:/
  attr_accessor :parsed

  named_scope :with_user, lambda { |user|
    raise TypeError unless user.is_a?(User)
    ut = User.table_name
    st = self.table_name
    {
      :conditions => { :user_id => user.id },
      :joins      => "INNER JOIN #{ut} AS wu_u ON #{st}.user_id = wu_u.uid AND wu_u.status != 'Anonymized'"
    }
  }

  def self.all(user=nil)
    if user.is_a? User
      conds = [ 'type = ? AND (user_id = 0 OR user_id = ?) AND code != ""', 'smiley', user.id ]
    else
      conds = [ 'type = ? AND user_id = 0 AND code != ""', 'smiley' ]
    end
    self.find(:all, :conditions => conds, :order => 'user_id DESC')
  end

  def self.post_icons
    self.find(
      :all,
      :conditions => [ 'type = ?', 'picon' ],
      :order      => 'id'
    )
  end

  def can_edit?(user)
    user.is_a?(User) && (user.is_adm? || self.user == user)
  end

  def can_delete?(user)
    self.can_edit?(user)
  end

  def url
    base_url = "http://www.studentibicocca.it/portale/forum/images"
    url      = read_attribute(:url)
    url      = base_url + "/" + url unless url =~ /^http/
    url
  end

end
