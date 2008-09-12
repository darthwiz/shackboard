# vim: set nowrap:
class AddFlattenedListSeqToForums < ActiveRecord::Migration
  def self.up
    change_table 'forums' do |t|
      t.column 'flattened_list_seq', :integer, :default => nil, :null => true
    end
    add_index :forums, :flattened_list_seq
    Forum.reset_column_information
    Forum.rebuild_flattened_list_seq!
  end

  def self.down
    change_table 'forums' do |t|
      t.remove 'flattened_list_seq'
    end
  end

end
