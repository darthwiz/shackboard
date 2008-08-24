# vim: set nowrap:
class AddGeomarks < ActiveRecord::Migration
  def self.up
    create_table 'geomarks', :force => true do |t|
      t.column :user_id, :integer, :null => false
      t.column :lat, :float, :null => false
      t.column :lng, :float, :null => false
      t.column :name, :string, :limit => 80, :null => true
      t.column :description, :text, :null => true
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
    end
    add_index :geomarks, :lat
    add_index :geomarks, :lng
    add_index :geomarks, [ :user_id, :created_at ]
    add_index :geomarks, :created_at
  end

  def self.down
    drop_table :geomarks
  end

end
