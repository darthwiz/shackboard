class Tag < ActiveRecord::Base
  belongs_to :taggable, :polymorphic => true
  belongs_to :user

  def self.find_all_by_object(obj)
    self.find_all_by_taggable_type_and_taggable_id(obj.class.to_s, obj.id)
  end

  def self.find_most_popular(n=30)
    self.find(
      :all,
      :select => "#{self.table_name}.tag, COUNT(*) AS count",
      :group  => "#{self.table_name}.tag",
      :order  => 'count DESC',
      :limit  => n
    )
  end

end
