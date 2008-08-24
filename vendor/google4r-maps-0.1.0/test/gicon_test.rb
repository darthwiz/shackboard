# Project:   google4r/maps
# File:      /test/maps_test.rb
# Author:    Manuel Holtgrewe <purestorm at ggnore dot net>
# Copyright: (c) 2007 by Manuel Holtgrewe
# License:   MIT License as follows:
#
# Permission is hereby granted, free of charge, to any person obtaining 
# a copy of this software and associated documentation files (the 
# "Software"), to deal in the Software without restriction, including 
# without limitation the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the 
# following conditions:
#
# The above copyright notice and this permission notice shall be included 
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

require File.expand_path(File.dirname(__FILE__) + '/test_helper')

require 'google4r/maps'

# Runs tests for the Google4R::Maps::GIcon class.
class GIconClass < Test::Unit::TestCase
  def test_creator_should_work_correctly
    icon = Google4R::Maps::GIcon.new
    assert_equal false, icon.copy
    
    icon = Google4R::Maps::GIcon.new(true)
    assert_equal true, icon.copy
  end
  
  def test_to_js_should_work_correctly_with_default_values
    expected = %Q{function() {
  var icon = new GIcon();
  
  return icon;
}}

    icon = Google4R::Maps::GIcon.new
    assert_equal expected, icon.to_js
  end
  
  def test_to_js_should_work_with_copy_icon_and_default_values
    expected = %Q{function() {
  var icon = new GIcon(G_DEFAULT_ICON);
  
  return icon;
}}
    
    icon = Google4R::Maps::GIcon.new(true)
    assert_equal expected, icon.to_js
  end
  
  def test_to_js_should_work_correctly_with_all_values_set
    expected = %Q{function() {
  var icon = new GIcon();
  icon.image = "image";
  icon.shadow = "shadow";
  icon.printImage = "print image";
  icon.printShadow = "print shadow";
  icon.transparent = "transparent";
  icon.iconSize = new GSize(1, 2);
  icon.shadowSize = new GSize(3, 4);
  icon.iconAnchor = new GPoint(5, 6);
  icon.infoWindowAnchor = new GPoint(7, 8);
  icon.imageMap = [ 10, 11, 12, 13, 14, 15 ];
  
  return icon;
}}
    
    icon = Google4R::Maps::GIcon.new
    icon.image = 'image'
    icon.shadow = 'shadow'
    icon.print_image = 'print image'
    icon.print_shadow = 'print shadow'
    icon.transparent = 'transparent'
    icon.icon_size = [ 1, 2 ]
    icon.shadow_size = [ 3, 4 ]
    icon.icon_anchor = [ 5, 6 ]
    icon.info_window_anchor = [ 7, 8 ]
    icon.image_map = [ [10,11], [12,13], [14,15] ]
    
    assert_equal expected, icon.to_js
  end
end
