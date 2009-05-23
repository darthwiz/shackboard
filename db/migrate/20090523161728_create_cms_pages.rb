class CreateCmsPages < ActiveRecord::Migration
  def self.up
    create_table :cms_pages do |t|
      t.text :text, :null => true
      t.string :title, :limit => 80, :null => false
      t.string :slug, :limit => 80, :null => false
      t.string :format, :limit => 10, :null => false, :default => 'bb'
      t.integer :created_by, :null => false
      t.integer :updated_by, :null => true
      t.integer :deleted_by, :null => true
      t.timestamps
      t.timestamp :deleted_at, :null => true
    end
    add_index "cms_pages", ["slug"], :name => "slug", :unique => true
  end

  def self.down
    drop_table :cms_pages
  end
end
