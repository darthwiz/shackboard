class StaticContent < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  belongs_to :user, :foreign_key => "updated_by"
  def save
    time = Time.now.to_i
    self.created_on = time if self.new_record?
    self.updated_on = time
    super
  end
end
