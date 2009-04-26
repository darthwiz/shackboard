class ChangeTimestampsOnDrafts < ActiveRecord::Migration
  def self.up
    rename_column :drafts, :timestamp, :updated_at
    add_column :drafts, :created_at, :integer
    Draft.connection.execute "UPDATE xmb_drafts SET created_at = updated_at"
  end

  def self.down
    rename_column :drafts, :updated_at, :timestamp
    remove_column :drafts, :created_at
  end
end
