class ConvertPmTableToUtf8 < ActiveRecord::Migration
  def self.up
    Pm.connection.execute("ALTER TABLE #{Pm.table_name} CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci")
  end

  def self.down
  end
end
