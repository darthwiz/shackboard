class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string  :obj_class, :null => false, :limit => 40
      t.integer :obj_id,    :null => false
      t.string  :tag,       :null => false, :limit => 40
    end
    add_index :xmb_tags, [ :obj_class, :obj_id, :tag ], :unique => true, :name => :unique_tags
  end

  def self.down
    drop_table :tags
  end
end
