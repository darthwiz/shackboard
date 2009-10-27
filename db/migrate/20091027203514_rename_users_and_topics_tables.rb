class RenameUsersAndTopicsTables < ActiveRecord::Migration
  def self.up
    User.connection.execute "RENAME TABLE xmb_members TO xmb_users"
    Topic.connection.execute "RENAME TABLE xmb_threads TO xmb_topics"
  end

  def self.down
    User.connection.execute "RENAME TABLE xmb_users TO xmb_members"
    Topic.connection.execute "RENAME TABLE xmb_topics TO xmb_threads"
  end
end
