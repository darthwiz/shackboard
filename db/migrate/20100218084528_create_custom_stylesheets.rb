class CreateCustomStylesheets < ActiveRecord::Migration

  def self.up
    create_table :custom_stylesheets do |t|
      t.string :obj_class, :limit => 40, :null => false
      t.integer :obj_id, :null => false
      t.text :css
    end
    add_index :custom_stylesheets, [ :obj_class, :obj_id ], :unique => true
  end

  def self.down
    drop_table :custom_stylesheets
  end

end
