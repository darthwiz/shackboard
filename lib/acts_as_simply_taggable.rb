module ActiveRecord
  module Acts
  end
end

module ActiveRecord::Acts::ActsAsSimplyTaggable

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_simply_taggable
      has_many :tags, :as => :taggable
      send :include, InstanceMethods
      named_scope :tagged_with, lambda { |tags|
        tags = tags.split(/,/).collect(&:slugify) if tags.is_a?(String)
        raise TypeError unless tags.is_a?(Array)
        tags = tags.uniq.sort
        cct  = self.table_name
        ccpk = self.primary_key
        cn   = self.to_s
        tt   = Tag.table_name
        if tags.empty?
          tags_cond  = 'tw_t.tag IS NULL'
          tags_count = 1
        else
          tags_cond  = "tw_t.taggable_type = '#{cn}' AND tw_t.tag IN (" + tags.collect { |i| "'#{i}'" }.join(', ') + ')'
          tags_count = tags.size
        end
        {
          :select     => "#{cct}.*, COUNT(*) AS tag_count",
          :joins      => "LEFT JOIN #{tt} AS tw_t ON #{cct}.#{ccpk} = tw_t.taggable_id",
          :conditions => tags_cond,
          :group      => "#{cct}.#{ccpk}",
          :having     => "tag_count = #{tags_count}",
        }
        # OPTIMIZE: the left join is probably unsuitable for large datasets and an
        # inner join would be better, along with a special handling of the empty
        # tag set (which is handled correctly by the left join right now)
      }
    end
  end

  module InstanceMethods
    def tag_with(tags, options={})
      absolute = !!options[:absolute]
      tags     = tags.split(/,/).collect(&:slugify) if tags.is_a?(String)
      raise TypeError unless tags.is_a?(Array)
      tag_objects  = self.tags
      present_tags = tag_objects.collect(&:tag)
      tags.each do |t|
        if !present_tags.include?(t)
          Tag.new(:taggable => self, :tag => t).save!
        end
      end
      if absolute
        tag_objects.each do |t|
          t.destroy if !tags.include?(t.tag)
        end
      end
      nil
    end
  end

end
