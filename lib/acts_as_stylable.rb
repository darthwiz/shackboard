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
      has_one :custom_stylesheet, :as => :stylable
    end
  end

  module InstanceMethods
    def custom_stylesheet_css=(css_text)
      css_obj = self.custom_stylesheet || CustomStylesheet.new
      return nil if css_text.blank? && css_obj.new_record?
      # XXX assuming current object is already persisted
      css_obj.stylable = self
      css_obj.css      = css_text
      css_obj.save
    end
  end

end
