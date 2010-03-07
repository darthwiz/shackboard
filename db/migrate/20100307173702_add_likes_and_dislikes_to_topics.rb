class AddLikesAndDislikesToTopics < ActiveRecord::Migration

  def self.up
    add_column :topics, :likes, :integer, :null => false, :default => 0
    add_column :topics, :dislikes, :integer, :null => false, :default => 0
    add_column :topics, :total_likes, :integer, :null => false, :default => 0
    add_index :topics, [ :fid, :total_likes ]
  end

  def self.down
    remove_column :topics, :likes
    remove_column :topics, :dislikes
    remove_column :topics, :total_likes
  end

end
