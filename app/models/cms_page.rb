class CmsPage < ActiveRecord::Base
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by
  belongs_to :updater, :class_name => 'User', :foreign_key => :updated_by
  validates_length_of :title, :minimum => 1
  validates_format_of :slug, :with => /\A[a-z0-9-]+\Z/
  validates_uniqueness_of :slug
  default_scope :conditions => { :deleted_by => nil }

  named_scope :tagged_with, lambda { |tag|
    raise TypeError unless tag.is_a?(String)
    cpt = self.table_name
    cn  = self.to_s
    tt  = Tag.table_name
    {
      :joins      => "INNER JOIN #{tt} AS tw_t ON #{cpt}.id = tw_t.obj_id",
      :conditions => [ 'tw_t.obj_class = ? AND tw_t.tag = ?', cn, tag ],
    }
  }

  def tag_with(tags)
    tags = tags.split(/,/).collect(&:slugify) if tags.is_a?(String)
    raise TypeError unless tags.is_a?(Array)
    obj_class    = self.class.to_s
    tag_objs     = Tag.find(:all, :conditions => [ 'obj_class = ? AND obj_id = ?', obj_class, self.id ])
    present_tags = tag_objs.collect(&:tag)
    tags.each do |t|
      if !present_tags.include?(t)
        Tag.new(:obj_class => obj_class, :obj_id => self.id, :tag => t).save!
      end
    end
  end

  def can_edit?(user)
    Group.find_by_name('portale_w').include?(user)
  end

  def self.can_edit?(user)
    Group.find_by_name('portale_w').include?(user)
  end

end
