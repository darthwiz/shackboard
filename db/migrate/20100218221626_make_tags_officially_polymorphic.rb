class MakeTagsOfficiallyPolymorphic < ActiveRecord::Migration

  def self.up
    rename_column :tags, :obj_id, :taggable_id
    rename_column :tags, :obj_class, :taggable_type
  end

  def self.down
    rename_column :tags, :taggable_type, :obj_class
    rename_column :tags, :taggable_id, :obj_id
  end

end
