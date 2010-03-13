class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string :commentable_type, :limit => 40, :null => false
      t.integer :commentable_id, :null => false
      t.integer :user_id, :null => false
      t.integer :modified_by, :null => true
      t.string :ip_address, :limit => 50, :null => false
      t.text :text
      t.timestamps
    end
    add_index :comments, [ :commentable_type, :commentable_id, :created_at ], :name => 'by_related_content'
    add_index :comments, [ :user_id, :created_at ], :name => 'by_user'
  end

  def self.down
    drop_table :comments
  end
end
