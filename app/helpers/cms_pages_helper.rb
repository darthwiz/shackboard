module CmsPagesHelper

  def page_trail_cms_page(obj, opts={})
    trail  = []
    trail << [ cleanup(obj.title), {} ]
  end

end
