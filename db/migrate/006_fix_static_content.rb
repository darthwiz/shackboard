# vim: set nowrap:
class FixStaticContent < ActiveRecord::Migration
  def self.up
    change_table 'static_contents' do |t|
      t.change 'label', :string, :limit => 40, :default => nil, :null => false
      t.column 'created_at', :timestamp
      t.column 'updated_at', :timestamp
      t.column 'format', :string, :limit => 10, :default => 'html', :null => false
      t.rename 'content', 'text'
    end
    StaticContent.reset_column_information
    StaticContent.find(:all).each do |i|
      i.created_at = Time.at(i.created_on)
      i.updated_at = Time.at(i.updated_on)
      i.save
    end
    change_table 'static_contents' do |t|
      t.remove 'created_on'
      t.remove 'updated_on'
    end
  end

  def self.down
    change_table 'static_contents' do |t|
      t.column 'created_on', :integer
      t.column 'updated_on', :integer
    end
    StaticContent.find(:all).each do |i|
      i.created_on = Time.at(i.created_at)
      i.updated_on = Time.at(i.updated_at)
      i.save
    end
    change_table 'static_contents' do |t|
      t.remove 'created_at'
      t.remove 'updated_at'
      t.remove 'format'
      t.rename 'content', 'text'
    end
  end
end
