class AddDeletedFieldToUsers < ActiveRecord::Migration
  def self.up
    add_column :members, :deleted_at, :integer, :null => true
  end

  def self.down
    remove_column :members, :deleted_at
  end
end
