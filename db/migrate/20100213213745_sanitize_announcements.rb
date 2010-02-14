class SanitizeAnnouncements < ActiveRecord::Migration

  def self.up
    remove_column :announcements, :says
    remove_column :announcements, :status
    remove_column :announcements, :special
    remove_column :announcements, :avr
    remove_column :announcements, :total
    remove_column :announcements, :cat
    add_column :announcements, :expires_at, :datetime, :null => true, :default => nil
    Announcement.reset_column_information
    Announcement.all.each { |i| i.update_attribute(:expires_at, Time.now) }
  end

  def self.down
    remove_column :announcements, :expires_at
    # nobody ever cared about the stuff that's being removed, so we just put it
    # back as integers in order to be able to roll back should the need arise.
    add_column :announcements, :says, :integer
    add_column :announcements, :status, :integer
    add_column :announcements, :special, :integer
    add_column :announcements, :avr, :integer
    add_column :announcements, :total, :integer
    add_column :announcements, :cat, :integer
  end

end
