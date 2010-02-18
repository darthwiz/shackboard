class CmsPage < ActiveRecord::Base
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by
  belongs_to :updater, :class_name => 'User', :foreign_key => :updated_by
  validates_length_of :title, :minimum => 1
  validates_format_of :slug, :with => /\A[a-z0-9-]+\Z/
  validates_uniqueness_of :slug
  default_scope :conditions => { :deleted_by => nil }

  named_scope :tagged_with, lambda { |tags|
    tags = tags.split(/,/).collect(&:slugify) if tags.is_a?(String)
    raise TypeError unless tags.is_a?(Array)
    tags = tags.uniq.sort
    cpt  = self.table_name
    cn   = self.to_s
    tt   = Tag.table_name
    if tags.empty?
      tags_cond  = 'tw_t.tag IS NULL'
      tags_count = 1
    else
      tags_cond  = "tw_t.obj_class = '#{cn}' AND tw_t.tag IN (" + tags.collect { |i| "'#{i}'" }.join(', ') + ')'
      tags_count = tags.size
    end
    {
      :select     => "#{cpt}.*, COUNT(*) AS tag_count",
      :joins      => "LEFT JOIN #{tt} AS tw_t ON #{cpt}.id = tw_t.obj_id",
      :conditions => tags_cond,
      :group      => "#{cpt}.id",
      :having     => "tag_count = #{tags_count}",
    }
    # OPTIMIZE: the left join is probably unsuitable for large datasets and an
    # inner join would be better, along with a special handling of the empty
    # tag set (which is handled correctly by the left join right now)
  }

  def tag_with(tags, options={})
    absolute = !!options[:absolute]
    tags     = tags.split(/,/).collect(&:slugify) if tags.is_a?(String)
    raise TypeError unless tags.is_a?(Array)
    obj_class    = self.class.to_s
    tag_objects  = Tag.find(:all, :conditions => [ 'obj_class = ? AND obj_id = ?', obj_class, self.id ])
    present_tags = tag_objects.collect(&:tag)
    tags.each do |t|
      if !present_tags.include?(t)
        Tag.new(:obj_class => obj_class, :obj_id => self.id, :tag => t).save!
      end
    end
    if absolute
      tag_objects.each do |t|
        t.destroy if !tags.include?(t.tag)
      end
    end
    nil
  end

  def tags
    Tag.find_by_object(self)
  end

  def css
    CustomStylesheet.find_by_object(self)
  end

  def css=(css_text)
    css_obj = self.css || CustomStylesheet.new
    return nil if css_text.blank? && css_obj.new_record?
    # XXX assuming current page is already persisted
    css_obj.obj_class = self.class.to_s
    css_obj.obj_id    = self.id
    css_obj.css       = css_text
    css_obj.save
  end

  def can_edit?(user)
    Group.find_by_name('portale_w').include?(user)
  end

  def self.can_edit?(user)
    Group.find_by_name('portale_w').include?(user)
  end

end
