require "#{RAILS_ROOT}/config/environment"
ENV['RAILS_ENV'] = ENV['RAILS_ENV'] || 'development'

namespace :cron do
  namespace :voting do

    desc "Update all voting-related data"
    task :update_all => [ :update_topic_votes, :update_users_karma ]

    desc "Update topic votes"
    task :update_topic_votes do
      Topic.update_votes_count!
    end

    desc "Update users' karma"
    task :update_users_karma do
      User.update_karma!
    end

  end
end
