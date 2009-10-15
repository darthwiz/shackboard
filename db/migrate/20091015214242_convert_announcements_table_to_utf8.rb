class ConvertAnnouncementsTableToUtf8 < ActiveRecord::Migration

  def self.up
    Announcement.connection.execute("ALTER TABLE #{Announcement.table_name} CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci")
  end

  def self.down
  end

end
