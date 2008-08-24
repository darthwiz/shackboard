# Project:   google4r/maps
# File:      /test/gmarker_test.rb
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

# Runs tests for the Google4R::Maps::GMarker class.
class GMarker < Test::Unit::TestCase
  def test_creator_should_work_correctly
    marker = Google4R::Maps::GMarker.new([1, 2])
    assert_equal [1, 2], marker.point
  end
  
  def test_to_js_should_work_correctly_with_default_values
    expected = %Q{function(icon) {
  var options = { dragCrossMove: false, clickable: true, bouncy: false, bounceGravity: 1 }
  if (icon != null) options['icon'] = icon;
  
  var marker = new GMarker(new GLatLng(1, 2), options);
  marker.disableDragging();
  
  /* Setup event handlers. */
  
  return marker;
}}

    marker = Google4R::Maps::GMarker.new([1, 2])
    assert_equal expected, marker.to_js
  end
  
  def test_to_js_should_work_correctly_with_all_values_set
    expected = %Q{function(icon) {
  var options = { dragCrossMove: true, title: "marker title", clickable: false, bouncy: true, bounceGravity: 2 }
  if (icon != null) options['icon'] = icon;
  
  var marker = new GMarker(new GLatLng(1, 2), options);
  marker.enableDragging();
  
  /* Setup event handlers. */
  
  return marker;
}}
    
    marker = Google4R::Maps::GMarker.new([1, 2])
    marker.drag_cross_move = true;
    marker.clickable = false;
    marker.draggable = true;
    marker.bouncy = true;
    marker.title = "marker title";
    marker.bounce_gravity = 2;
    
    assert_equal expected, marker.to_js
  end
  
  def test_to_js_should_work_correctly_with_event_handlers
    expected = %Q{function(icon) {
  var options = { dragCrossMove: false, clickable: true, bouncy: false, bounceGravity: 1 }
  if (icon != null) options['icon'] = icon;
  
  var marker = new GMarker(new GLatLng(1, 2), options);
  marker.disableDragging();
  
  /* Setup event handlers. */
  GEvent.addListener(marker, "click", function() {
  // my handler
// code
});
  GEvent.addListener(marker, "click", function() {
  // my other handler
// code
});
  
  return marker;
}}

    marker = Google4R::Maps::GMarker.new([1, 2])
    
    marker.onclick_handlers << "// my handler\n// code"
    marker.onclick_handlers << "// my other handler\n// code"
    
    assert_equal expected, marker.to_js
  end
  
  def test_info_window_html_should_work_correctly
    expected = %Q{function(icon) {
  var options = { dragCrossMove: false, clickable: true, bouncy: false, bounceGravity: 1 }
  if (icon != null) options['icon'] = icon;
  
  var marker = new GMarker(new GLatLng(1, 2), options);
  marker.disableDragging();
  
  /* Setup event handlers. */
  GEvent.addListener(marker, "click", function() {
  marker.openInfoWindowHtml("some html");
});
  
  return marker;
}}

    marker = Google4R::Maps::GMarker.new([1, 2])

    marker.info_window_html = "some html"

    assert_equal expected, marker.to_js
  end
end
