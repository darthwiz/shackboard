require RAILS_ROOT + '/lib/acts_as_stylable.rb'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::ActsAsStylable)
