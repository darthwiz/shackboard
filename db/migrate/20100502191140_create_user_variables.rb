class CreateUserVariables < ActiveRecord::Migration

  def self.up
    create_table :user_variables do |t|
      t.integer :user_id, :null => false
      t.string :key, :limit => 40, :null => false
      t.text :value
    end
    add_index :user_variables, [ :user_id, :key ], :unique => true
  end

  def self.down
    drop_table :user_variables
  end

end
