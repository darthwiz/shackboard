class ExtractBlogPostComments < ActiveRecord::Migration
  def self.up
    create_table :blog_comments do |t|
      t.integer   :user_id, :null => false
      t.timestamp :created_at, :null => false
      t.timestamp :updated_at, :null => true
      t.string    :title, :limit => 200, :null => true
      t.text      :text, :null => false
      t.integer   :blog_post_id, :null => false
      t.string    :ip_address, :limit => 50, :null => false
      t.boolean   :unread, :default => true
      t.integer   :modified_by, :null => true
    end
    BlogPost.find(:all, :conditions => 'blog_post_id > 0').each do |bp|
      bc = BlogComment.new
      bc.attributes.keys.each { |key| bc[key] = bp[key] }
      bc.save
      bp.destroy
    end
    remove_column :blog_posts, :blog_post_id
    add_index :blog_comments, [ :blog_post_id ]
  end

  def self.down
    add_column :blog_posts, :blog_post_id, :integer, :null => true
    BlogPost.reset_column_information
    BlogComment.find(:all).each do |bc|
      bp = BlogPost.new
      bp.attributes.keys.each { |key| bp[key] = bc[key] }
      bp.save
    end
    drop_table :blog_comments
  end
end
