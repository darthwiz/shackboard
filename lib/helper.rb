class Helper
  include Singleton
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper
  include ApplicationHelper

  def self.full_sanitizer
    @@full_sanitizer ||= HTML::FullSanitizer.new
  end

  def h(text)
    ERB::Util.h(text)
  end

  def self.method_missing(method, *args)
    self.instance.send(method, *args)
  end

end
