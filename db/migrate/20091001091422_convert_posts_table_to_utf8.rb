class ConvertPostsTableToUtf8 < ActiveRecord::Migration
  def self.up
    Post.connection.execute("ALTER TABLE #{Post.table_name} CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci")
  end

  def self.down
  end
end
