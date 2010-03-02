module ActiveRecord
  module Acts
  end
end

module ActiveRecord::Acts::ActsAsVotable

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_votable
      has_many :votes, :as => :votable
      send :include, InstanceMethods
      named_scope :voted_by, lambda { |user|
        raise TypeError unless user.is_a?(User)
        cct  = self.table_name   # current class table
        ccpk = self.primary_key  # current class primary key
        cn   = self.to_s         # class name
        vt   = Vote.table_name   # votes table
        {
          :select => "#{cct}.*",
          :joins  => "INNER JOIN #{vt} AS vb_v ON #{cct}.#{ccpk} = vb_v.votable_id AND vb_v.user_id = #{user.id}",
        }
      }
    end
  end

  module InstanceMethods
    def vote_with(user, points)
      raise TypeError unless points.is_a?(Integer)
      raise TypeError unless user.is_a?(User)
      users_vote        = self.votes.by_user(user).first || Vote.new(:user => user, :votable => self)
      users_vote.points = points
      users_vote.save!
    end
  end

end
