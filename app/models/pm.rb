class Pm < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name table_name_prefix + "u2u"
  set_primary_key "u2uid"
  # validations {{{
  validates_numericality_of :dateline
  validates_presence_of :message
  validates_each :msgfrom, :msgto do |record, attribute, value|
    record.errors.add(attribute, "user not found") \
      unless User.find_by_username(value)
  end
  validates_inclusion_of :folder, :in => ['inbox', 'outbox', 'trash']
  # }}}
  def Pm.unread_for(user) # {{{
    return nil unless user.is_a? User
    Pm.count(:conditions => ['msgto = ? AND status = ?', user.username, 'new'])
  end # }}}
  def from # {{{
    User.find_by_username(self.msgfrom) || User.new
  end # }}}
  def to # {{{
    User.find_by_username(self.msgto) || User.new
  end # }}}
  def read? # {{{
    self.status == 'read'
  end # }}}
  def Pm.count_from_to(from, to) # {{{
    raise TypeError unless from.is_a? User
    raise TypeError unless to.is_a? User
    conds = [ "msgfrom = ? AND msgto = ? AND folder = 'inbox'",
      from.username, to.username ]
    Pm.count(:conditions => conds)
  end # }}}
  def Pm.find_all_by_words(user, words, opts={}) # {{{
    username          = ActiveRecord::Base.send(:sanitize_sql, user.username)
    words2c           = Pm.new.send(:words_to_conds, words)
    conds             = ["msgto = ? AND folder = 'inbox'", user.username]
    conds[0]         += " AND " + words2c unless words2c.empty?
    opts[:conditions] = conds
    Pm.find(:all, opts)
  end # }}}
  private
  def words_to_conds(words) # {{{
    conds = ""
    words.each do |i|
      word   = ActiveRecord::Base.send(:sanitize_sql, i)
      conds << " AND (subject LIKE '%#{word}%'"
      conds << " OR msgfrom LIKE '%#{word}%'"
      conds << " OR message LIKE '%#{word}%')"
    end
    conds.sub(/^ AND /, '')
  end # }}}
end
