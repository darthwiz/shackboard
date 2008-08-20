# vim: set nowrap:
class AddViewsToBlogs < ActiveRecord::Migration
  def self.up
    change_table 'blogs' do |t|
      t.column 'view_count', :integer, :default => 0, :null => false
      t.column 'last_post_id', :integer, :default => nil, :null => true
      t.column 'last_post_at', :timestamp, :default => nil, :null => true
    end
    add_index :blogs, :last_post_at
  end

  def self.down
    change_table 'blogs' do |t|
      t.remove_index :column => [ :last_post_at ]
      t.remove 'view_count'
      t.remove 'last_post_id'
      t.remove 'last_post_at'
    end
  end
end
