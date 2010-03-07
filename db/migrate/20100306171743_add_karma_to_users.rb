class AddKarmaToUsers < ActiveRecord::Migration

  def self.up
    add_column :users, :karma, :integer, :limit => 1, :null => true
  end

  def self.down
    remove_column :users, :karma
  end

end
