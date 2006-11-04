module ActiveRecord::MagicFixes
  require 'strip_helper.rb'
  require 'iso_helper.rb'
  include ActiveRecord::StripHelper
  include ActiveRecord::IsoHelper
  def before_save # {{{
    _before_write
  end # }}}
  def after_find # {{{
    _after_read
    strip_slashes
  end # }}}
  def after_save # {{{
    _after_read
  end # }}}
end
