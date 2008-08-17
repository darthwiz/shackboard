# vim: set nowrap:
class AddBlogs < ActiveRecord::Migration
  
  def self.up
    create_table 'categories', :force => true do |t|
      t.column :user_id, :integer, :default => nil, :null => true
      t.column :name, :string, :limit => 80, :null => false
      t.column :object_class, :string, :limit => 40, :default => nil, :null => true
    end
    add_index :categories, :user_id

    create_table 'blog_posts', :force => true do |t|
      t.column :user_id, :integer, :null => false
      t.column :timestamp, :timestamp, :null => false
      t.column :title, :string, :limit => 200, :default => nil, :null => true
      t.column :text, :text, :default => nil, :null => true
      t.column :blog_post_id, :integer, :default => nil, :null => true
      t.column :ip_address, :string, :limit => 16, :default => nil, :null => true
    end
    add_index :blog_posts, [ :user_id, :timestamp ]
    add_index :blog_posts, [ :blog_post_id ]
    add_index :blog_posts, [ :timestamp ]
    add_index :blog_posts, [ :title ]
    add_index :blog_posts, [ :ip_address ]

    create_table 'blog_posts_categories', :id => false, :force => true do |t|
      t.column :blog_post_id, :integer, :null => false
      t.column :category_id, :integer, :null => false
    end
    add_index :blog_posts_categories, :blog_post_id
    add_index :blog_posts_categories, :category_id
  end

  def self.down
    drop_table :categories
    drop_table :blog_posts
    drop_table :blog_posts_categories
  end
end
