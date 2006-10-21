class Rank < ActiveRecord::Base
  set_table_name table_name_prefix + "ranks"
  attr_accessor :freakfactor
end
