class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.string :votable_type, :limit => 40, :null => false
      t.integer :votable_id, :null => false
      t.integer :user_id, :null => false
      t.integer :points, :limit => 1, :null => false
      t.timestamps
    end
    add_index :votes, [ :votable_type, :votable_id, :user_id ], :unique => true
    add_index :votes, [ :user_id ]
  end

  def self.down
    drop_table :votes
  end
end
