# Project:   google4r/maps
# File:      /test/gmap_test.rb
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

# Runs tests for the Google4R::Maps::GMap2 class.
class GMap2Test < Test::Unit::TestCase
  def test_attributes_are_correctly_set_in_creator
    map = Google4R::Maps::GMap2.new("var name", "dom id")

    assert_equal "dom id", map.div_id
    assert_equal "var name", map.name

    assert_equal [], map.icons
    assert_equal [], map.markers
    assert_equal [ :large_map, :scale, :map_type ], map.controls
    assert_equal :normal, map.map_type
    assert_equal true, map.dragging_enabled
    assert_equal true, map.info_window_enabled
    assert_equal false, map.double_click_zoom_enabled
    assert_equal :auto, map.center
    assert_equal :auto, map.zoom
    assert_equal nil, map.onload_js
  end
  
  def test_create_marker_works
    map = Google4R::Maps::GMap2.new("var name", "dom id")

    i = map.markers.length
    maybe_marker = map.create_marker([1,2])
    
    assert_kind_of Google4R::Maps::GMarker, maybe_marker
    assert_equal [1, 2], maybe_marker.point
    assert map.markers.include?(maybe_marker)
    assert_equal i+1, map.markers.length
  end
  
  def test_create_icon_works
    map = Google4R::Maps::GMap2.new("var name", "dom id")

    i = map.icons.length
    maybe_icon = map.create_icon()
    
    assert_kind_of Google4R::Maps::GIcon, maybe_icon
    assert_equal false, maybe_icon.copy
    assert map.icons.include?(maybe_icon)
    assert_equal i+1, map.icons.length
  end

  def test_to_html_works_correctly_with_default_values
    Google4R::Maps::GMap2.any_instance.stubs(:to_js).returns("<gmap 2 js>")
    
    map = Google4R::Maps::GMap2.new("var name", "dom id")
    
    expected = %Q{<div id="dom id"></div>
<script type="text/javascript" charset="utf-8">
//<![CDATA[
/* Create a variable to hold the GMap2 instance and the icons in. */
var var name;
var var name_icons;

function var name_loader() {
<gmap 2 js>
}

if (window.addEventListener) { /* not MSIE */
  window.addEventListener('load', function() { var name_loader(); }, false);
} else { /* MSIE */
  window.attachEvent('onload', function() { var name_loader(); }, false);
}

/* Optional Javascript */
if (window.addEventListener) { /* not MSIE */
  window.addEventListener('unload', function() { GUnload(); }, false);
} else { /* MSIE */
  window.attachEvent('onunload', function() { GUnload(); }, false);
}
// ]]>
</script>}

    assert_equal expected, map.to_html
  end

  def test_to_html_works_correctly_with_no_gunload_handler
    Google4R::Maps::GMap2.any_instance.stubs(:to_js).returns("<gmap 2 js>")
    
    map = Google4R::Maps::GMap2.new("var name", "dom id")
    map.options[:register_gunload] = false
    
    expected = %Q{<div id="dom id"></div>
<script type="text/javascript" charset="utf-8">
//<![CDATA[
/* Create a variable to hold the GMap2 instance and the icons in. */
var var name;
var var name_icons;

function var name_loader() {
<gmap 2 js>
}

if (window.addEventListener) { /* not MSIE */
  window.addEventListener('load', function() { var name_loader(); }, false);
} else { /* MSIE */
  window.attachEvent('onload', function() { var name_loader(); }, false);
}

/* Optional Javascript */
// ]]>
</script>}

    assert_equal expected, map.to_html
  end
  
  
  def test_to_js_works_correctly_with_default_values_and_without_icons_or_markers
    map = Google4R::Maps::GMap2.new("var_name", "dom id")
    
    expected = %Q{/* Create GMap2 instance. */
var_name = new GMap2(document.getElementById("dom id"), {  });
var_name.setCenter(new GLatLng(0, 0), #{Google4R::Maps::GMap2::DEFAULT_ZOOM});

/* Set map options. */
var_name.setMapType(G_NORMAL_MAP);
var_name.enableDragging();
var_name.enableInfoWindow();
var_name.disableDoubleClickZoom();
var_name.disableContinuousZoom();

/* Add controls to the map. */
var_name.addControl(new GLargeMapControl());
var_name.addControl(new GScaleControl());
var_name.addControl(new GMapTypeControl());

/* Create global variable holding all icons. */
var_name_icons = new Array();

/* Add markers to the map. */

/* User supplied Javascript */
}
    
    assert_equal expected, map.to_js
  end
  
  def test_to_js_works_correctly_with_default_values
    map = Google4R::Maps::GMap2.new("var_name", "dom id")

    map.icons << mock()
    map.icons.last.stubs(:to_js).returns('<mock icon #1 js>')
    map.icons << mock()
    map.icons.last.stubs(:to_js).returns('<mock icon #2 js>')
    map.markers << mock()
    map.markers.last.stubs(:point).returns([ 10, 10 ])
    map.markers.last.stubs(:icon).returns(map.icons[1])
    map.markers.last.stubs(:to_js).returns('<mock marker #1 js>')
    map.markers << mock()
    map.markers.last.stubs(:point).returns([ 20, 20 ])
    map.markers.last.stubs(:icon).returns(map.icons[0])
    map.markers.last.stubs(:to_js).returns('<mock marker #2 js>')
    map.markers << mock()
    map.markers.last.stubs(:point).returns([ 10, 10 ])
    map.markers.last.stubs(:icon).returns(nil)
    map.markers.last.stubs(:to_js).returns('<mock marker #3 js>')
    
    expected = %Q{/* Create GMap2 instance. */
var_name = new GMap2(document.getElementById("dom id"), {  });
var_name.setCenter(new GLatLng(15, 15), var_name.getBoundsZoomLevel(new GLatLngBounds(new GLatLng(10, 10), new GLatLng(20, 20))));

/* Set map options. */
var_name.setMapType(G_NORMAL_MAP);
var_name.enableDragging();
var_name.enableInfoWindow();
var_name.disableDoubleClickZoom();
var_name.disableContinuousZoom();

/* Add controls to the map. */
var_name.addControl(new GLargeMapControl());
var_name.addControl(new GScaleControl());
var_name.addControl(new GMapTypeControl());

/* Create global variable holding all icons. */
var_name_icons = new Array();
var_name_icons.push(<mock icon #1 js>());
var_name_icons.push(<mock icon #2 js>());

/* Add markers to the map. */
var_name.addOverlay(<mock marker #1 js>(var_name_icons[1]));
var_name.addOverlay(<mock marker #2 js>(var_name_icons[0]));
var_name.addOverlay(<mock marker #3 js>());

/* User supplied Javascript */
}
    
    assert_equal expected, map.to_js
  end
  
  def test_to_js_works_correctly_with_changed_values
    map = Google4R::Maps::GMap2.new("var_name", "dom id")
    map.center = [-122.083739, 37.423021 ]
    map.continuous_zoom_enabled = true
    map.controls = [ :small_map, :small_zoom ]
    map.div_id = "other dom id"
    map.double_click_zoom_enabled = true
    map.draggable_cursor = 'draggable cursor'
    map.dragging_cursor = 'dragging cursor'
    map.dragging_enabled = false
    map.info_window_enabled = false
    map.map_type = :hybrid
    map.name = "other_var_name"
    map.size = [ 100, 200 ]
    map.zoom = 10
    
    map.icons << mock()
    map.icons.last.stubs(:to_js).returns('<mock icon #1 js>')
    map.icons << mock()
    map.icons.last.stubs(:to_js).returns('<mock icon #2 js>')
    map.markers << mock()
    map.markers.last.stubs(:icon).returns(map.icons[1])
    map.markers.last.stubs(:to_js).returns('<mock marker #1 js>')
    map.markers << mock()
    map.markers.last.stubs(:icon).returns(map.icons[0])
    map.markers.last.stubs(:to_js).returns('<mock marker #2 js>')
    map.markers << mock()
    map.markers.last.stubs(:icon).returns(nil)
    map.markers.last.stubs(:to_js).returns('<mock marker #3 js>')

    expected = %Q{/* Create GMap2 instance. */
other_var_name = new GMap2(document.getElementById("other dom id"), { draggableCursor: "draggable cursor", draggingCursor: "dragging cursor", size: new GSize(100, 200) });
other_var_name.setCenter(new GLatLng(#{map.center[0]}, #{map.center[1]}), #{map.zoom});

/* Set map options. */
other_var_name.setMapType(G_HYBRID_MAP);
other_var_name.disableDragging();
other_var_name.disableInfoWindow();
other_var_name.enableDoubleClickZoom();
other_var_name.enableContinuousZoom();

/* Add controls to the map. */
other_var_name.addControl(new GSmallMapControl());
other_var_name.addControl(new GSmallZoomControl());

/* Create global variable holding all icons. */
other_var_name_icons = new Array();
other_var_name_icons.push(<mock icon #1 js>());
other_var_name_icons.push(<mock icon #2 js>());

/* Add markers to the map. */
other_var_name.addOverlay(<mock marker #1 js>(other_var_name_icons[1]));
other_var_name.addOverlay(<mock marker #2 js>(other_var_name_icons[0]));
other_var_name.addOverlay(<mock marker #3 js>());

/* User supplied Javascript */
}

    assert_equal expected, map.to_js
  end
  
  def test_center_auto_works_correctly
    map = Google4R::Maps::GMap2.new("var_name", "dom id")
    map.center = :auto
    
    map.create_marker([10, 10])
    map.create_marker([20, 20])
    
    result = map.to_js
    assert_not_nil result.index("var_name.setCenter(new GLatLng(15, 15)"), "result is #{result.inspect}"
  end
  
  def test_zoom_auto_works_correctly
    map = Google4R::Maps::GMap2.new("var_name", "dom id")
    map.center = [ 0, 0 ]
    map.zoom = :auto
    
    map.create_marker([10, 10])
    map.create_marker([20, 20])
    
    result = map.to_js
    assert_not_nil result.index("var_name.setCenter(new GLatLng(0, 0), var_name.getBoundsZoomLevel(new GLatLngBounds(new GLatLng(10, 10), new GLatLng(20, 20))))"), "result is #{result.inspect}"
  end
end
