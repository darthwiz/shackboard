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
        {
          :select     => "#{cct}.*, COUNT(*) AS tag_count",
          :joins      => "LEFT JOIN #{tt} AS tw_t ON tw_t.taggable_type = '#{cn}' AND #{cct}.#{ccpk} = tw_t.taggable_id",
          :conditions => 'tw_t.tag IS NULL',
          :group      => "#{cct}.#{ccpk}",
          :having     => "tag_count = 1",
        }
        else
        {
          :select     => "#{cct}.*, COUNT(*) AS tag_count",
          :joins      => "INNER JOIN #{tt} AS tw_t ON tw_t.taggable_type = '#{cn}' AND #{cct}.#{ccpk} = tw_t.taggable_id",
          :conditions => "tw_t.tag IN (" + tags.collect { |i| "'#{i}'" }.join(', ') + ')',
          :group      => "#{cct}.#{ccpk}",
          :having     => "tag_count = #{tags.size}",
        }
        end
        # FIXME counting from this scope will yield wrong results when an
        # object has more than one tag, so don't do it until this is fixed.
      }

      named_scope :including_tags, :include => :tags
    end
  end

  module InstanceMethods
    def tags_as_text=(tags)
      @tags_as_text = tags.to_s
    end

    def tags_as_text
      self.tags.collect(&:tag).join(', ')
    end

    def tag_with(tags, user, options={})
      absolute = !!options[:absolute]
      tags     = tags.split(/,/).collect(&:slugify) if tags.is_a?(String)
      raise TypeError unless tags.is_a?(Array)
      raise TypeError unless user.is_a?(User)
      tag_objects  = self.tags
      present_tags = tag_objects.collect(&:tag)
      tags.each do |t|
        if !present_tags.include?(t)
          Tag.new(:taggable => self, :tag => t, :user => user).save!
        end
      end
      if absolute
        tag_objects.each do |t|
          if !tags.include?(t.tag)
            can_edit   = false
            tagged_obj = t.taggable
            can_edit   = true if t.user == user || (tagged_obj.respond_to?(:can_edit?) && tagged_obj.can_edit?(user))
            # A tag can be removed by a user if that user put it on the object
            # or has editing permissions on the object.
            t.destroy if can_edit
          end
        end
      end
      nil
    end
  end

end
