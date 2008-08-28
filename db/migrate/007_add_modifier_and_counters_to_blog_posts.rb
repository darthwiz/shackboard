# vim: set nowrap:
class AddModifierAndCountersToBlogPosts < ActiveRecord::Migration
  def self.up
    change_table 'blog_posts' do |t|
      t.column 'modified_by', :integer, :default => nil, :null => true
      t.column 'comments_count', :integer, :default => 0, :null => false
      t.column 'unread_comments_count', :integer, :default => 0, :null => false
    end
    BlogPost.reset_column_information
    BlogPost.find(:all).each do |i|
      i.comments_count        = BlogPost.count(:conditions => [ 'blog_post_id = ?', i.id ])
      i.unread_comments_count = BlogPost.count(:conditions => [ 'blog_post_id = ? AND unread = 1', i.id ])
      i.save
    end
  end

  def self.down
    change_table 'blog_posts' do |t|
      t.remove 'modified_by'
      t.remove 'comments_count'
      t.remove 'unread_comments_count'
    end
  end

end
