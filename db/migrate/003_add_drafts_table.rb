class AddDraftsTable < ActiveRecord::Migration
  def self.up
    create_table :drafts do |t|
      t.column :user_id,     :integer
      t.column :timestamp,   :integer
      t.column :object_type, :string, :limit => 30
      t.column :object,      :text,   :limit => 2000000
    end
    add_index 'drafts', [ 'user_id', 'timestamp', 'object_type' ],
      :name => 'drafts_index'
  end

  def self.down
    drop_table :drafts
  end
end
