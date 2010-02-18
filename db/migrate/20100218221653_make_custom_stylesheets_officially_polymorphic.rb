class MakeCustomStylesheetsOfficiallyPolymorphic < ActiveRecord::Migration

  def self.up
    rename_column :custom_stylesheets, :obj_id, :stylable_id
    rename_column :custom_stylesheets, :obj_class, :stylable_type
  end

  def self.down
    rename_column :custom_stylesheets, :stylable_type, :obj_class
    rename_column :custom_stylesheets, :stylable_id, :obj_id
  end

end
