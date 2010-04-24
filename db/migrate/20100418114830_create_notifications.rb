class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.integer  :recipient_id,    :null => false
      t.integer  :actor_id,        :null => true                # could be a robot
      t.string   :notifiable_type, :null => false, :limit => 40
      t.integer  :notifiable_id,   :null => false               # we always want to link to something
      t.datetime :created_at
      t.boolean  :seen,            :null => false, :default => false
      t.string   :kind,            :null => false, :limit => 40 # we want to know what happened
      t.text     :info,            :null => true                # might not be always needed
    end
    add_index :notifications, [ :recipient_id, :seen, :created_at ]
  end

  def self.down
    drop_table :notifications
  end
end
