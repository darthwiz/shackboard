class AddCreationTimeToTags < ActiveRecord::Migration

  def self.up
    add_column :tags, :created_at, :datetime, :null => true
    add_index :tags, [ :created_at ]
  end

  def self.down
    remove_column :tags, :created_at
  end

end
