class UserVariable < ActiveRecord::Base
  belongs_to :user
  serialize :value

  named_scope :with_key, lambda { |key| { :conditions => [ "#{self.table_name}.`key` = ?", key.to_s ] } }
end
