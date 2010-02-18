require RAILS_ROOT + '/lib/acts_as_simply_taggable.rb'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::ActsAsSimplyTaggable)
