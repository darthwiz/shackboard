# vim: set nowrap:
class AddBlogTable < ActiveRecord::Migration
  
  def self.up
    create_table 'blogs', :force => true do |t|
      t.column 'name', :string, :limit => 80, :default => nil, :null => false
      t.column 'label', :string, :limit => 40, :default => nil, :null => false
      t.column 'description', :text, :default => nil, :null => true
      t.column 'user_id', :integer, :null => false
      t.timestamps
    end
    add_index :blogs, [ :user_id, :label ]

    change_table 'blog_posts' do |t|
      t.references :blog
      t.rename 'timestamp', 'created_at'
      t.column 'updated_at', :timestamp
    end

    change_table 'categories' do |t|
      t.rename 'object_class', 'owner_class'
      t.column 'owner_id', :integer, :null => false
      t.column 'label', :string, :limit => 40, :default => nil, :null => false
      t.remove_index :column => [ :user_id ]
      t.index [ :user_id, :label ]
      t.index [ :owner_class, :owner_id ]
    end
    change_column 'categories', 'owner_class', :string, :null => false
    change_column 'categories', 'user_id', :integer, :null => false
  end

  def self.down
    drop_table 'blogs'
    change_table 'blog_posts' do |t|
      t.remove 'blog_id'
      t.remove 'updated_at'
      t.rename 'created_at', 'timestamp'
    end

    change_table 'categories' do |t|
      t.rename 'owner_class', 'object_class'
      t.remove 'owner_id'
      t.remove 'label'
      t.remove_index :column => [ :owner_class, :owner_id ]
      t.remove_index :column => [ :user_id, :label ]
      t.index [ :user_id ]
    end
  end

end
