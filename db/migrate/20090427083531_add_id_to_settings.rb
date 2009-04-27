class AddIdToSettings < ActiveRecord::Migration
  def self.up
    tn = Settings.table_name
    Settings.connection.execute("ALTER TABLE #{tn} ADD id INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST")
  end

  def self.down
    remove_column :settings, :id
  end
end
