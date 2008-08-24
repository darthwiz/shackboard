#--
# Project:   google4r
# File:      lib/google4r/geocoder.rb
# Author:    Manuel Holtgrewe <purestorm at ggnore dot net>
# Copyright: (c) 2006 by Manuel Holtgrewe
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
#++
# This file defines the code which is necessary to access the Google Maps 
# Geocoder.

require 'net/http'
require 'uri'
require 'yaml'

module Google4R
  # === On Javascript Generation
  #
  # We have decided not to create variables for the created GIcons and GMarkers.
  # Instead, the generated Javascript are anonymous functions which return the
  # objects.
  #
  # For example, if you create a marker then the following JS code could be created:
  #
  #   function() {
  #     var marker = new GMarker(new GLatLng(42, 42));
  #     marker.clickable = false;
  #   }
  #
  # This function is then used to add markers to the map in the following way:
  #
  #   var map = new GMap(/* ... */)
  #   // ...
  #   map.addMarker(function(){
  #     var marker = new GMarker(new GLatLng(42, 42));
  #     marker.clickable = false;
  #   }());
  #
  # The reasoning behind is that the only thing you want to touch in the generated
  # JS is the GMap2 instance. If you want to remove any markers then you better create
  # them directly in your Javascript.
  #--
  # TODO: All those line collecting and then joining could prove *slow*.
  # TODO: Allow Rails-ish :foo => 'bar' options for all attributes to constructors.
  #++
  module Maps
    # Thrown if no API has been given or it is incorrect.
    class KeyException < Exception
    end
  
    # Thrown when it was impossible to connect to the server.
    class ConnectionException < Exception
    end

    # GMap2 instances can be converted to the HTML/JS that is necessary to render a GMap2
    # widget.
    #
    # The API documentation provided by Google will be insightful:
    # http://www.google.com/apis/maps/documentation/reference.html#GMap2
    #
    # === Example
    #
    #   map = GMap2.new("map", "map")
    #   map.to_html # => %q{<div id="map"></div><script type="text/javascript">var map = new GMap2...}
    #--
    # TODO: Use GMarkerManager instead of adding Markers directly?
    #++
    class GMap2
      # Default for zoom if zoom is :auto and no markers have been added.
      DEFAULT_ZOOM = 13
      
      # Default for center if center is :auto and no markers have been added.
      DEFAULT_CENTER = [ 0, 0 ].freeze
      
      # An array of GIcon objects. Use #create_icon to create new GIcon object.
      attr_reader :icons
      
      # An array of GMarker objects. Use #create_marker to create new GMarke object.
      attr_reader :markers
      
      # The name of the Javascript variable to create to hold the GMap2 instance.
      attr_accessor :name

      # The id of the <div> id to create.
      attr_accessor :div_id
      
      # Array with the size of the map: [ width, height ]. The map will use its container's
      # size if unset. Defaults to nil.
      attr_accessor :size
      
      # String with the CSS name of the cursor to use when dragging the map. Defaults to
      # nil.
      attr_accessor :draggable_cursor
      
      # String with the CSS name of the cursor to use when the map is draggable. Defaults to
      # nil.
      attr_accessor :dragging_cursor
      
      # An array with control to display on the map. Valid entries are :small_map, :large_map,
      # :small_zoom, :scale, :map_type. They are directly mapped to the controls documented on
      # http://www.google.com/apis/maps/documentation/reference.html#GControlImpl.
      # Defaults to [ :large_map, :scale, :map_type ].
      attr_accessor :controls

      # The map types to allow by default. Can be one of :normal, :satellite and :hybrid. These
      # symbols are mapped to G_NORMAL_MAP, G_SATELLITE_MAP and G_HYBRID_MAP in JS. Defaults
      # to :normal.
      attr_accessor :map_type
      
      # true iff dragging is enabled - defaults to true
      attr_accessor :dragging_enabled
      
      # true iff info windows are show - defaults to true
      attr_accessor :info_window_enabled
      
      # true iff zooming by double clicking is enabled - defaults to false
      attr_accessor :double_click_zoom_enabled
      
      # true iff smooth zooming is enabled - defaults to false
      attr_accessor :continuous_zoom_enabled
      
      # String with arbitrary Javascript that you want executed after the map has been 
      # initialized and all markers have been placed on the map. Defaults to nil.
      attr_accessor :onload_js
      
      # Zoom level of the map. Defaults to :auto. If set to :auto then the map is zoomed so that
      # all markers are visible if the map is centered over them. Ranges from 17 (closest to
      # earth) to 0 (world view).
      # If no markers have been added and zoom is :auto then zoom is set to 13.
      attr_accessor :zoom
      
      # Array with [ latitude, longitude ] of the center of the map. Defaults to :auto.
      # If set to :auto then the map will be centered over all added markers. If set to 
      # :auto and no markers have been added then the value [ 0, 0 ] will be used.
      attr_accessor :center
      
      # Hash with options that do not directly map into GMap2 properties and that only
      # influence the Javascript that is generated.
      #
      # At the moment, valid keys are:
      #
      # :register_gunload:: Boolean. true iff to add a callback to GUnload() to the "onunload"
      #                     event of <body>. Defaults to true.
      attr_reader :options
      
      # Create a new MapWidget instance.
      #
      # === Parameters
      #
      # name:: The name of the Javascript variable to create to hold the GMap2 instance.
      # div_id:: The id of the <div /> tag to create.
      #--
      # options:: A hash with options.
      #
      # Valid options entries are:
      #
      # :size:: Array ([ width, height ]) with two integers. By default, the map will use the size of its container.
      # :draggable_cursor:: A string with the CSS name of the cursor to use when dragging the map.
      # :dragging_cursor:: A string with the CSS name of the cursor to use when the map is draggable.
      #++
      #
      # === Example
      #
      # GMap2.new("map", "map")
      def initialize(name, div_id)
        @icons = Array.new
        @markers = Array.new
        @options = { :register_gunload => true }
        
        # defaults
        @controls = [ :large_map, :scale, :map_type ]
        @map_type = :normal
        @dragging_enabled = true
        @info_window_enabled = true
        @double_click_zoom_enabled = false
        @continuous_zoom_enabled = false
        @center = :auto
        @zoom = :auto
        @onload_js = nil
        
        # initialization
        @name = name
        @div_id = div_id
      end
      
      # Creates the <div> tag and the <script> tag and puts self.to_js into the <script>
      # tag.
      def to_html
        result = Array.new
        result << %Q{<div id="#{@div_id}"></div>}
        result << %Q{<script type="text/javascript" charset="utf-8">}
        result << %Q{//<![CDATA[}
        result << %Q{/* Create a variable to hold the GMap2 instance and the icons in. */}
        result << %Q{var #{@name};}
        result << %Q{var #{@name}_icons;}
        result << ""
        # Yes, there are some really nice things that MSIE forces you to do!
        result << %Q|function #{@name}_loader() {|
        result << self.to_js
        result << %Q|}|
        result << ""
        result << %Q|if (window.addEventListener) { /* not MSIE */|
        result << %Q|  window.addEventListener('load', function() { #{@name}_loader(); }, false);|
        result << %Q|} else { /* MSIE */|
        result << %Q|  window.attachEvent('onload', function() { #{@name}_loader(); }, false);|
        result << %Q|}|
        result << ""

        # Add optional Javascript - like the GUnload() call.
        result << %Q|/* Optional Javascript */|
        if options[:register_gunload] then
          result << %Q|if (window.addEventListener) { /* not MSIE */|
          result << %Q|  window.addEventListener('unload', function() { GUnload(); }, false);|
          result << %Q|} else { /* MSIE */|
          result << %Q|  window.attachEvent('onunload', function() { GUnload(); }, false);|
          result << %Q|}|
        end
        
        result << %Q{// ]]>}
        result << %Q{</script>}
        
        return result.join("\n")
      end
      
      # Creates the necessary HTML for the GMap.
      def to_js
        lines = Array.new
        
        # Create GMap2 instance.
        options = []
        options << %Q{draggableCursor: "#{@draggable_cursor}"} unless @draggable_cursor.nil?
        options << %Q{draggingCursor: "#{@dragging_cursor}"} unless @dragging_cursor.nil?
        options << %Q{size: new GSize(#{@size[0]}, #{@size[1]})} unless @size.nil?
        
        # Calculate the center value if the map is to be centered over all markers.
        center = (@center == :auto) ? self.calculate_auto_center : @center
        
        # Let the JS GMap2 object resolve automatic zoom levels if necessary.
        zoom = 
          if @zoom == :auto then
            if @markers.length == 0 then
              DEFAULT_ZOOM
            else
              bounds = self.calculate_auto_bounds
              "#{@name}.getBoundsZoomLevel(new GLatLngBounds(new GLatLng(#{bounds[0]}, #{bounds[1]}), new GLatLng(#{bounds[2]}, #{bounds[3]})))"
            end
          else
            @zoom
          end

        lines << %Q{/* Create GMap2 instance. */}
        lines << %Q{#{@name} = new GMap2(document.getElementById("#{@div_id}"), { #{options.join(', ')} });}
        lines << %Q{#{@name}.setCenter(new GLatLng(#{center[0]}, #{center[1]}), #{zoom});}
        lines << ""
        
        # Set map options.
        lines << %Q{/* Set map options. */}
        lines << %Q{#{@name}.setMapType(G_#{@map_type.to_s.upcase}_MAP);}
        
        if @dragging_enabled then
          lines << %Q{#{@name}.enableDragging();}
        else
          lines << %Q{#{@name}.disableDragging();}
        end
        if @info_window_enabled then
          lines << %Q{#{@name}.enableInfoWindow();}
        else
          lines << %Q{#{@name}.disableInfoWindow();}
        end
        if @double_click_zoom_enabled then
          lines << %Q{#{@name}.enableDoubleClickZoom();}
        else
          lines << %Q{#{@name}.disableDoubleClickZoom();}
        end
        if @continuous_zoom_enabled then
          lines << %Q{#{@name}.enableContinuousZoom();}
        else
          lines << %Q{#{@name}.disableContinuousZoom();}
        end
        lines << ""
        
        # Add controls.
        lines << %Q{/* Add controls to the map. */}
        self.controls.each { |control| lines << %Q{#{@name}.addControl(new #{control_constructor(control)});} }
        lines << ""
        
        # Add icons.
        lines << %Q{/* Create global variable holding all icons. */}
        lines << %Q{#{@name}_icons = new Array();}
        self.icons.each { |icon| lines << "#{@name}_icons.push(#{icon.to_js}());"}
        lines << ""
        
        # Add markers.
        lines << %Q{/* Add markers to the map. */}
        self.markers.each do |marker|
          icon_index = icons.index(marker.icon)
          icon_str =
            if icon_index.nil? then
              ""
            else
             "#{@name}_icons[#{icon_index}]"
            end 
          lines << %Q{#{@name}.addOverlay(#{marker.to_js}(#{icon_str}));}
        end
        lines << ""
        
        # Add user supplied Javascript.
        lines << %Q{/* User supplied Javascript */}
        if not @onload_js.nil? then
          lines << @onload_js.to_s
        end
        lines << ""
        
        return lines.join("\n")
      end
      
      # Creates a new GIcon instance that is then available for the GMarker instances on this
      # GMap2.
      #
      # The parameters passed to this method are the same as to the constructor of the GIcon
      # class.
      def create_icon(*options)
        result = GIcon.new(*options)
        @icons << result
        return result
      end
      
      # Creates a new GMarker instance on this GMap2 instance. Use this factory method to create
      # your GMarker instances instead of the GMarker constructor directly.
      #
      # The parameters passed to this method are the same as the ones passed to the constructor
      # of the GMarker instance.
      def create_marker(*options)
        result = GMarker.new(*options)
        @markers << result
        return result
      end
      
      protected
      
        # Returns the constructor for the GControl instance that belongs to the symbol
        # passed. The known symbols are the ones also accepted in the controls attribute.
        def control_constructor(symbol)
          @control_constructors ||=
            {
              :small_map  => 'GSmallMapControl()',
              :large_map  => 'GLargeMapControl()',
              :small_zoom => 'GSmallZoomControl()',
              :scale      => 'GScaleControl()',
              :map_type   => 'GMapTypeControl()'
            }
          
          return @control_constructors[symbol]
        end
        
        # Calculates the center of all markers and returns the [ latitude, longitude ]
        # of this point.
        # Returns [ 0, 0 ] if
        def calculate_auto_center
          min_lat, min_lng, max_lat, max_lng = self.calculate_auto_bounds
          
          return [ (max_lat + min_lat) / 2, (max_lng + min_lng) / 2 ]
        end
        
        # Returns smallest rectangle [ min_lat, min_lng, max_lat, max_lng ] that contains
        # all markers of this GMarker.
        def calculate_auto_bounds
          return [ 0, 0, 0, 0 ] if @markers.length == 0
          
          max_lat, max_lng = @markers.first.point
          min_lat, min_lng = @markers.first.point
          
          @markers.slice(1, @markers.length).each do |marker|
            if marker.point[0] < min_lat then min_lat = marker.point[0] end
            if marker.point[0] > max_lat then max_lat = marker.point[0] end
            if marker.point[1] < min_lng then min_lng = marker.point[1] end
            if marker.point[1] > max_lng then max_lng = marker.point[1] end
          end
          
          return [ min_lat, min_lng, max_lat, max_lng ]
        end
    end
    
    # Javascript GMarker instances represent markers. The Ruby class GMarker allows you to
    # generate the Javascript which creates a new GMarker.
    #
    # Use GMap2#create_marker to create new markers instead of intanciating them directly.
    #
    # The Google API documentation can be found here: http://www.google.com/apis/maps/documentation/reference.html#GMarker
    #
    # === Example
    #
    #   map = GMap2.new("map", "map", :size => [ 100, 200 ])
    #  
    #   my_icon = map.create_icon
    #   ...
    #
    #   marker = GMarker.new([ -42.0, 0 ])
    #   marker.title = "Nice Title!"
    #   marker.icon = my_icon
    #   map.markers << marker
    #--
    # TODO: Add support for info windows.
    #++
    class GMarker
      # A GIcon instance that represents the icon to use for your class. The GIcon object
      # must also be available in the belonging GMap. The default icon provided by Google
      # is used iff this value is nil.
      attr_accessor :icon
      
      # An array with the [ latitude, longitude ] of the GMarker instance.
      attr_accessor :point
      
      # True iff to keep the marker underneath the cursor. Defaults to false.
      attr_accessor :drag_cross_move
      
      # String to display when hovering long enough over the marker.
      attr_accessor :title
      
      # True iff the marker is to respond to click events. Defaults to true.
      attr_accessor :clickable
      
      # True iff the marker is to be draggable. Defaults to false.
      attr_accessor :draggable
      
      # True iff the marker is to bounce on the map when dropped. Defaults to false.
      attr_accessor :bouncy
      
      # "Gravity" to use for bouncy markers. Defaults to 1.
      attr_accessor :bounce_gravity
      
      # An array of Javascript to execute when the user clicks on the map. Each Javascript
      # string will be wrapped into a function so global variables are not available outside
      # this function.
      #
      # The marker object will available as "marker" in the handler code you pass in.
      #
      # Example: <code>function(){ alert("My marker is " + marker); }</code>
      attr_accessor :onclick_handlers
      
      # HTML String value to display in the window opened by the JS method GMarker.openInfoWindowHtml()
      # when the marker is clicked on. If unset then no window is opened.
      attr_accessor :info_window_html
      
      # Creates a new GMarker instance at the given [ latitude, longitude ] point.
      def initialize(point)
        @point = point
        
        @onclick_handlers = Array.new
        
        # initialize defaults
        @drag_cross_move = false
        @clickable = true
        @draggable = false
        @bouncy = false
        @bounce_gravity = 1
      end
      
      # Creates the Javascript to create a new marker. Creates an anonymous function
      # returning a marker as documented in Google4R::Maps.
      def to_js
        lines = Array.new

        # build constructor options
        options = []
        options << "dragCrossMove: #{(@drag_cross_move == true).to_s}"
        options << "title: #{@title.inspect}" unless @title.nil?
        options << "clickable: #{(@clickable == true).to_s}"
        options << "bouncy: #{(@bouncy == true).to_s}"
        options << "bounceGravity: #{@bounce_gravity}"

        # build JS to create GMarker
        lines << "var options = { #{options.join(", ")} }"
        lines << "if (icon != null) options['icon'] = icon;"
        lines << ""
        lines << "var marker = new GMarker(new GLatLng(#{@point.join(", ")}), options);"
        
        # set options settable with accessor
        if @draggable then
          lines << "marker.enableDragging();"
        else
          lines << "marker.disableDragging();"
        end
        lines << ""
        
        # build event handler setup
        lines << "/* Setup event handlers. */"
        onclick_handlers.each do |function_body|
          lines << %Q{GEvent.addListener(marker, "click", function() {
  #{function_body}
});}
        end
        
        # add event handler generated for the info_window_html attribute
        if not info_window_html.nil? then
          lines << %Q{GEvent.addListener(marker, "click", function() {
  marker.openInfoWindowHtml(#{@info_window_html.inspect});
});}
        end
        
        # build result
        result = Array.new
        result << "function(icon) {"
        result += lines.map { |str| "  " + str }
        result << "  "
        result << "  return marker;"
        result << "}"
        
        return result.join("\n")
      end
    end
    
    # The Ruby GIcon class wraps around the Javascript GIcon class to create custom icons for markers.
    #
    # You should not create GIcon instances directly but use the GMap2#create_icon factory method
    # for this.
    #
    # See http://www.google.com/apis/maps/documentation/reference.html#GIcon for more details on the attributes.
    class GIcon
      # True iff to create the GIcon object based on G_DEFAULT_ICON.
      #--
      # TODO: We might choose to allow Ruby GIcon instances here to allow creation based on those GIcons *later* on.
      #++
      attr_accessor :copy
      
      # URL of the image to use as the foreground.
      attr_accessor :image
      
      # URL of the image to use as the shadow.
      attr_accessor :shadow
      
      # The pixel size of the foreground image of the icon as [width, height].
      attr_accessor :icon_size

      # The pixel size of the shadow image as [width, height].
      attr_accessor :shadow_size
      
      # Pixel coordinates relative to the top left corner of the icon image at which
      # the icon is to be anchored to the map as [width, height].
      attr_accessor :icon_anchor
      
      # Pixel coordinates relative to the top left corner of the icon image at which
      # the info window is to be anchored to the map as [width, height].
      attr_accessor :info_window_anchor
      
      # The URL of the foreground icon image used for printed maps as [width, height].
      # It must be the same size as the main icon image given by image.
      attr_accessor :print_image
      
      # The URL of the foreground icon image used for printed maps in Firefox/Mozilla. 
      # It must be the same size as the main icon image given by image.
      attr_accessor :moz_print_image
      
      # The URL of the shadow image used for printed maps. It should be a GIF image since 
      # most browsers cannot print PNG images.
      attr_accessor :print_shadow
      
      # The URL of a virtually transparent version of the foreground icon image used to capture 
      # click events in Internet Explorer. This image should be a 24-bit PNG version of the main
      # icon image with 1% opacity, but the same shape and size as the main icon.
      attr_accessor :transparent
      
      # An array of [width, height] specifications to use to identify the clickable part in
      # other browsers than MSIE.
      attr_accessor :image_map
      
      # If the parameter copy is set to true then the generated Javascript will base the icon
      # on G_DEFAULT_ICON. You only have to specify the parameters you want to override in this
      # case.
      #
      # G_DEFAULT_ICON based markers - what does this mean? A part of the generated code will
      # look like this:
      #
      #   var marker = new GIcon(G_DEFAULT_ICON)
      #   marker.image = "..."
      #   // other properties of the marker
      def initialize(copy=false)
        @copy = (copy == true)
      end
      
      # Creates an anonymous Javascript function that creates a GIcon. See the notes on the
      # Google4R::Maps module on the generated Javascript. The generated Javascript looks
      # as follows:
      #
      #   function() {
      #     var icon = new GIcon();
      #     icon.image = "image";
      #     icon.shadow = "shadow";
      #     icon.printImage = "print image";
      #     icon.printShadow = "print shadow";
      #     icon.transparent = "transparent";
      #     icon.iconSize = new GSize(1, 2);
      #     icon.shadowSize = new GSize(3, 4);
      #     icon.iconAnchor = new GPoint(5, 6);
      #     icon.infoWindowAnchor = new GPoint(7, 8);
      #     icon.imageMap = [ 10, 11, 12, 13, 14, 15 ];
      # 
      #     return icon;
      #   }
      def to_js
        lines = []
        
        if @copy then
          lines << %Q{var icon = new GIcon(G_DEFAULT_ICON);}
        else
          lines << %Q{var icon = new GIcon();}
        end
        
        # String properties.
        [
          [ :image, 'image' ], [ :shadow, 'shadow' ], [ :print_image, 'printImage' ], [ :moz_print_image, 'mozPrintImage' ],
          [ :print_shadow, 'printShadow' ], [ :transparent, 'transparent' ]
        ].each do |ruby_name, js_name|
          lines << %Q{icon.#{js_name} = #{self.send(ruby_name).dump};} unless self.send(ruby_name).nil?
        end
        
        # GSize properties.
        [ [ :icon_size, 'iconSize' ], [ :shadow_size, 'shadowSize' ] ].each do |ruby_name, js_name|
          lines << %Q{icon.#{js_name} = new GSize(#{self.send(ruby_name).join(', ')});} unless self.send(ruby_name).nil?
        end
        
        # GPoint properties.
        [ [ :icon_anchor, 'iconAnchor' ], [ :info_window_anchor, 'infoWindowAnchor' ] ].each do |ruby_name, js_name|
          lines << %Q{icon.#{js_name} = new GPoint(#{self.send(ruby_name).join(', ')});} unless self.send(ruby_name).nil?
        end
        
        # The image map.
        lines << %Q{icon.imageMap = [ #{@image_map.flatten.join(', ')} ];} unless @image_map.nil?
        
        # Build result string.
        result = Array.new
        
        result << "function() {"
        result += lines.map { |str| "  " + str }
        result << "  "
        result << "  return icon;"
        result << "}"
        return result.join("\n")
      end
    end
    
    # Allows to geocode a location.
    #
    # Uses the Google Maps API to find information about locations specified by strings. You need
    # a Google Maps API key to use the Geocoder.
    #
    # The result has the same format as documented in [1] (within <kml>) if it is directly converted 
    # into Ruby: A value consisting of nested Hashes and Arrays.
    #
    # After querying, you can access the last server response code using #last_status_code.
    #
    # Notice that you can also use Google's geolocator service to locate ZIPs by querying for the 
    # ZIP and country name.
    #
    # Usage Example:
    #
    #   api_key = 'abcdefg'
    #   geocoder = Google4R::Maps::Geocoder.new(api_key)
    #   result = geocoder.query("1 Infinite Loop, Cupertino")
    #   puts result["Placemark"][0]["address"] # => "1 Infinite Loop, Cupertino, CA 95014"
    #
    # 1:: http://www.google.de/apis/maps/documentation/#Geocoding_Structured
    class Geocoder
      # Returns the last status code returned by the server.
      attr_reader :last_status_code
    
      # The hardcoded URL of Google's geolocator API.
      GET_URL = 'http://maps.google.com/maps/geo?q=%s&output=%s&key=%s'.freeze
    
      # Response code constants.
      G_GEO_SUCCESS = 200
      G_GEO_SERVER_ERROR = 500
      G_GEO_MISSING_ADDRESS = 601
      G_GEO_UNKNOWN_ADDRESS = 602
      G_UNAVAILABLE_ADDRESS = 603
      G_GEO_BAD_KEY = 610
    
      # Creates a new Geocoder object. You have to supply a valid Google Maps
      # API key.
      #
      # === Parameters
      #
      # key::The Google Maps API key.
      # client::Your Google Maps client ID (this is only required for enterprise keys).
      def initialize(key, client=nil)
        @api_key = key
        @client = client
      end
      
      # === Parameters
      #
      # query:: The place to locate.
      #
      # === Exceptions
      #
      # Throws a KeyException if the key for this Geocoder instance is invalid and
      # throws a ConnectionException if the Geocoder instance could not connect to
      # Google's server or an server error occured.
      #
      # === Return Values
      #
      # Returns data in the same format as documented in [1] 
      #
      # Example of returned values:
      #
      #   {
      #     "name": "1600 Amphitheatre Parkway, Mountain View, CA, USA",
      #     "Status": {
      #       "code": 200,
      #       "request": "geocode"
      #     },
      #     "Placemark": [
      #       {
      #         "address": "1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA",
      #         "AddressDetails": {
      #           "Country": {
      #             "CountryNameCode": "US",
      #             "AdministrativeArea": {
      #               "AdministrativeAreaName": "CA",
      #               "SubAdministrativeArea": {
      #                 "SubAdministrativeAreaName": "Santa Clara",
      #                 "Locality": {
      #                   "LocalityName": "Mountain View",
      #                   "Thoroughfare": {
      #                     "ThoroughfareName": "1600 Amphitheatre Pkwy"
      #                   },
      #                   "PostalCode": {
      #                     "PostalCodeNumber": "94043"
      #                   }
      #                 }
      #               }
      #             }
      #           },
      #           "Accuracy": 8
      #         },
      #         "Point": {
      #           "coordinates": [-122.083739, 37.423021, 0]
      #         }
      #       }
      #     ]
      #   }
      #
      # 1:: http://www.google.de/apis/maps/documentation/#Geocoding_Structured
      #++
      # TODO: Remove the workaround below once this ticket is cleared and the change widely distributed: http://code.whytheluckystiff.net/syck/ticket/27
      #--
      def query(query)
        # Check that a Google Maps key has been specified.
        raise KeyException.new("Cannot use Google geocoder without an API key.") if @api_key.nil?
      
        # Compute the URL to send a GET query to.
        url = URI.escape(GET_URL % [ query, 'json', @api_key.to_s ])
        url += "&client=#{@client}" unless @client.nil?
        
        # Perform the query via HTTP.
        response = 
          begin
            Net::HTTP.get_response(URI.parse(url))
          rescue Exception => e
            raise ConnectionException.new("Could not connect to '#{url}': #{e.message}")
          end
        body = response.body
      
        # Parse the response JSON. We can simply use YAML::load here. I discovered this
        # on why's page: http://redhanded.hobix.com/inspect/yamlIsJson.html
        #
        # We need a workaround to parse the ultra compact JSON from Google, however, because
        # of this bug: http://code.whytheluckystiff.net/syck/ticket/27
        result = YAML::load(body.gsub(/([:,])([^\s])/, '\1 \2'))
        
        @last_status_code = result['Status']['code']
      
        # Check that the query was successful.
        if @last_status_code == G_GEO_BAD_KEY then
          raise KeyException.new("Invalid API key: '#{@api_key}'.")
        elsif @last_status_code == G_GEO_SERVER_ERROR then
          raise ConnectionException.new("There was an error when connecting to the server. Result code was: #{status}.") 
        elsif [ G_GEO_MISSING_ADDRESS, G_GEO_UNKNOWN_ADDRESS, G_UNAVAILABLE_ADDRESS ].include?(@last_status_code) then
          return nil
        end

        return result
      end
    end
  end
end
