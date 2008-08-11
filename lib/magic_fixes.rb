module ActiveRecord::MagicFixes
  require 'strip_helper.rb'
  include ActiveRecord::StripHelper

  def after_find
    strip_slashes
  end

end
