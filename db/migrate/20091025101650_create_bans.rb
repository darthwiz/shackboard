class CreateBans < ActiveRecord::Migration
  def self.up
    create_table :bans do |t|
      t.integer :user_id, :null => false
      t.integer :moderator_id, :null => false
      t.integer :forum_id, :null => false
      t.datetime :created_at, :null => false
      t.datetime :expires_at
      t.text :reason
    end
    add_index :bans, [ :user_id, :forum_id, :expires_at ]
  end


  def self.down
    drop_table :bans
  end
end
