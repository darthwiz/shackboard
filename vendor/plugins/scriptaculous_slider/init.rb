ActionView::Helpers::AssetTagHelper::register_javascript_include_default "slider"
require "#{directory}/lib/helpers/slider_helper.rb"
ActionView::Base.send :include, ActionView::Helpers::SliderHelper
#ActionView::Base::load_helpers "#{directory}/lib/helpers/"
