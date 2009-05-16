require "#{RAILS_ROOT}/config/environment"
ENV['RAILS_ENV'] = ENV['RAILS_ENV'] || 'development'

namespace :cron do
  namespace :counters do

    desc "Fix all counters"
    task :fix_all_counters => [ :fix_users_counters, :fix_topics_counters, :fix_forums_counters ]

    desc "Fix all users' post counters"
    task :fix_users_counters do
      User.fix_post_count!
    end

    desc "Fix all topics' post counters"
    task :fix_topics_counters do
      Topic.fix_post_count!
    end

    desc "Fix all forums' post counters"
    task :fix_forums_counters do
      Forum.fix_post_count!
    end

  end
end
