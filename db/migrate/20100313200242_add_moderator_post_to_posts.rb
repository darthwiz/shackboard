class AddModeratorPostToPosts < ActiveRecord::Migration

  def self.up
    add_column :posts, :moderator_post, :boolean, :null => true, :default => false
  end

  def self.down
    remove_column :posts, :moderator_post
  end

end
