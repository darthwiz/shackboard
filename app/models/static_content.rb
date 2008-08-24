class StaticContent < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  belongs_to :user, :foreign_key => "updated_by"
  
  def self.find_or_prepare(label)
    content       = StaticContent.find_by_label(label) || StaticContent.new
    content.label = label if content.new_record?
    content
  end

end
