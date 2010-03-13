module ActiveRecord
  module Acts
  end
end

module ActiveRecord::Acts::ActsAsCommentable

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_commentable
      send :include, InstanceMethods
      has_many :comments, :as => :commentable
    end
  end

  module InstanceMethods
  end

end
