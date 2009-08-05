class ConvertTopicsTableToUtf8 < ActiveRecord::Migration
  def self.up
    Topic.connection.execute("ALTER TABLE #{Topic.table_name} CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci")
  end

  def self.down
  end
end
