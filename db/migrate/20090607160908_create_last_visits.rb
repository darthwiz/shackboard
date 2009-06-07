class CreateLastVisits < ActiveRecord::Migration
  def self.up
    create_table :last_visits do |t|
      t.integer :user_id, :null => false
      t.string  :object_type, :limit => 40, :null => false
      t.integer :object_id, :null => false
      t.integer :created_at
      t.string  :ip, :limit => 40, :null => true
    end
    add_index "last_visits", ["user_id", "object_type", "object_id"], :unique => true, :name => "by_object"
    add_index "last_visits", ["user_id", "created_at"], :name => "by_time"
  end

  def self.down
    drop_table :last_visits
  end
end
