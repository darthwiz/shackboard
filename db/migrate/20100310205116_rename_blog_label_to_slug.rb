class RenameBlogLabelToSlug < ActiveRecord::Migration

  def self.up
    rename_column :blogs, :label, :slug
  end

  def self.down
    rename_column :blogs, :slug, :label
  end

end
