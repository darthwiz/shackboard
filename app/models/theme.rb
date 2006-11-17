class Theme < ActiveRecord::Base
  set_table_name table_name_prefix + "themes"
  def css
    "studentibicocca"
  end
end
