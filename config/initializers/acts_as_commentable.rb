require RAILS_ROOT + '/lib/acts_as_commentable.rb'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::ActsAsCommentable)
