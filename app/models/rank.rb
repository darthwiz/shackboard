class Rank < ActiveRecord::Base
  set_table_name table_name_prefix + "ranks"
  @@maxposts = nil
  @@ranks    = nil
  def Rank.evaluate(posts) # {{{
    @@maxposts = User.maximum(:postnum) unless @@maxposts
    @@ranks    = Rank.find(:all, :order => 'posts') unless @@ranks
    n = @@ranks.length
    r = @@ranks[0]
    (0...n).each do |i|
      r = @@ranks[i] if posts >= @@maxposts.to_f / 4**(n - i)
    end
    return r
  end # }}}
end
