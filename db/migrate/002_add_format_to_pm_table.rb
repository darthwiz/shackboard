class AddFormatToPmTable < ActiveRecord::Migration
  def self.up
    add_column :u2u, :format, :string, :limit => 16, :default => 'bb'
  end

  def self.down
    raise IrreversibleMigration
    remove_column :u2u, 'format'
  end
end
