module ActiveRecord
  module Acts
  end
end

module ActiveRecord::Acts::ActsAsStylable

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_stylable
      send :include, InstanceMethods
    end
  end

  module InstanceMethods
    def custom_stylesheet
      CustomStylesheet.find_by_object(self)
    end

    def custom_stylesheet_css=(css_text)
      css_obj = self.custom_stylesheet || CustomStylesheet.new
      return nil if css_text.blank? && css_obj.new_record?
      # XXX assuming current page is already persisted
      css_obj.obj_class = self.class.to_s
      css_obj.obj_id    = self.id
      css_obj.css       = css_text
      css_obj.save
    end
  end

end
