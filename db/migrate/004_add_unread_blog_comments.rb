# vim: set nowrap:
class AddUnreadBlogComments < ActiveRecord::Migration
  def self.up
    change_table 'blog_posts' do |t|
      t.column 'unread', :boolean, :default => false, :null => false
    end
  end

  def self.down
    change_table 'blog_posts' do |t|
      t.remove 'unread'
    end
  end

end
