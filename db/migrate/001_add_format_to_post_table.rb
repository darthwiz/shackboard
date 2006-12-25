class AddFormatToPostTable < ActiveRecord::Migration
  def self.up
    add_column :posts, :format, :string, :limit => 16, :default => 'bb'
  end

  def self.down
    raise IrreversibleMigration
    remove_column :posts, 'format'
  end
end
