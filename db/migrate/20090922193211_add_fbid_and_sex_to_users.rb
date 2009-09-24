class AddFbidAndSexToUsers < ActiveRecord::Migration
  def self.up
    add_column :members, :fbid, :integer, :null => true, :limit => 8, :default => nil
    add_column :members, :sex, :string, :null => true, :limit => 1, :default => nil
    add_index :members, :fbid, :unique => true
  end

  def self.down
    remove_index :members, :fbid
    remove_column :members, :fbid
    remove_column :members, :sex
  end
end
