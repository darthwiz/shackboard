require RAILS_ROOT + '/lib/acts_as_votable.rb'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::ActsAsVotable)
