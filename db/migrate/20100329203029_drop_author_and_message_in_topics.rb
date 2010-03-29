class DropAuthorAndMessageInTopics < ActiveRecord::Migration

  def self.up
    remove_column :topics, :author
    remove_column :topics, :message
  end

  def self.down
    add_column :topics, :author, :string, :limit => 40, :null => true
    add_column :topics, :message, :text, :null => true
  end

end
