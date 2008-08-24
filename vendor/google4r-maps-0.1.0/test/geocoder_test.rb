# Project:   google4r/maps
# File:      /test/test_geocoder.rb
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

require 'test/key'

# Runs tests for the Google4R::Maps::Geocoder class. You have to provide a file named
# "key.rb" in the test directory which defines the constant GOOGLE_MAPS_KEY.
# This value will be used as the key for the "real" tests against the Google
# servers.
class GeocoderTest < Test::Unit::TestCase
  def setup
    @test_adress = "Janitell Rd, Colorado Springs, CO"

    @valid_query_result = %q{{"name":"Janitell Rd, Colorado Springs, CO","Status":{"code":200,"request":"geocode"},"Placemark":[{"address":"Janitell Rd, Colorado Springs, CO 80906, USA","AddressDetails":{"Country":{"CountryNameCode":"US","AdministrativeArea":{"AdministrativeAreaName":"CO","SubAdministrativeArea":{"SubAdministrativeAreaName":"El Paso","Locality":{"LocalityName":"Colorado Springs","Thoroughfare":{"ThoroughfareName":"Janitell Rd"},"PostalCode":{"PostalCodeNumber":"80906"}}}}},"Accuracy": 6},"Point":{"coordinates":[-104.790060,38.795330,0]}},{"address":"Janitell Rd, Stratmoor, CO 80906, USA","AddressDetails":{"Country":{"CountryNameCode":"US","AdministrativeArea":{"AdministrativeAreaName":"CO","SubAdministrativeArea":{"SubAdministrativeAreaName":"El Paso","Locality":{"LocalityName":"Stratmoor","Thoroughfare":{"ThoroughfareName":"Janitell Rd"},"PostalCode":{"PostalCodeNumber":"80906"}}}}},"Accuracy": 6},"Point":{"coordinates":[-104.790390,38.789840,0]}},{"address":"Janitell Rd, CO 80906, USA","AddressDetails":{"Country":{"CountryNameCode":"US","AdministrativeArea":{"AdministrativeAreaName":"CO","SubAdministrativeArea":{"SubAdministrativeAreaName":"El Paso","Thoroughfare":{"ThoroughfareName":"Janitell Rd"},"PostalCode":{"PostalCodeNumber":"80906"}}}},"Accuracy": 6},"Point":{"coordinates":[-104.794390,38.803230,0]}}]}}

    @valid_parsed_result = 
    {"Status"=>{"code"=>200, "request"=>"geocode"},
     "name"=>"Janitell Rd, Colorado Springs, CO",
     "Placemark"=>
      [{"AddressDetails"=>
         {"Country"=>
           {"AdministrativeArea"=>
             {"SubAdministrativeArea"=>
               {"Locality"=>
                 {"LocalityName"=>"Colorado Springs",
                  "Thoroughfare"=>{"ThoroughfareName"=>"Janitell Rd"},
                  "PostalCode"=>{"PostalCodeNumber"=>"80906"}},
                "SubAdministrativeAreaName"=>"El Paso"},
              "AdministrativeAreaName"=>"CO"},
            "CountryNameCode"=>"US"},
          "Accuracy"=>6},
        "Point"=>{"coordinates"=>[-104.79006, 38.79533, 0]},
        "address"=>"Janitell Rd, Colorado Springs, CO 80906, USA"},
       {"AddressDetails"=>
         {"Country"=>
           {"AdministrativeArea"=>
             {"SubAdministrativeArea"=>
               {"Locality"=>
                 {"LocalityName"=>"Stratmoor",
                  "Thoroughfare"=>{"ThoroughfareName"=>"Janitell Rd"},
                  "PostalCode"=>{"PostalCodeNumber"=>"80906"}},
                "SubAdministrativeAreaName"=>"El Paso"},
              "AdministrativeAreaName"=>"CO"},
            "CountryNameCode"=>"US"},
          "Accuracy"=>6},
        "Point"=>{"coordinates"=>[-104.79039, 38.78984, 0]},
        "address"=>"Janitell Rd, Stratmoor, CO 80906, USA"},
       {"AddressDetails"=>
         {"Country"=>
           {"AdministrativeArea"=>
             {"SubAdministrativeArea"=>
               {"Thoroughfare"=>{"ThoroughfareName"=>"Janitell Rd"},
                "PostalCode"=>{"PostalCodeNumber"=>"80906"},
                "SubAdministrativeAreaName"=>"El Paso"},
              "AdministrativeAreaName"=>"CO"},
            "CountryNameCode"=>"US"},
          "Accuracy"=>6},
        "Point"=>{"coordinates"=>[-104.79439, 38.80323, 0]},
        "address"=>"Janitell Rd, CO 80906, USA"}]}
    
    @empty_result = 
    {
      "Status" => { "code" => :number, "request" => "request" },
      "Placemark" => []
    }
    
    @invalid_key_result = %q{{"name":"Janitell Rd, Colorado Springs, CO","Status":{"code":610,"request":"geocode"}}}
  end
  
  def teardown
  end
  
  
  def test_query_performs_correct_query_without_client
    # required parameters
    query = 'query'
    key = 'key'
    
    # setup stubs & mocks
    url = URI.escape(Google4R::Maps::Geocoder::GET_URL % [ @test_adress, 'json', key ])
    fake_response = stub()
    fake_response.stubs(:body).times(1).with().returns(@valid_query_result)
    Net::HTTP.stubs(:get_response).returns(fake_response).times(1).with(URI.parse(url))
    
    # perform query
    geocoder = Google4R::Maps::Geocoder.new(key)
    geocoder.query(@test_adress)
  end
  
  def test_query_performs_correct_query_with_client
    # required parameters
    query = 'query'
    key = 'key'
    
    # setup stubs & mocks
    url = URI.escape(Google4R::Maps::Geocoder::GET_URL % [ @test_adress, 'json', key ])
    fake_response = stub()
    fake_response.stubs(:body).times(1).with().returns(@valid_query_result)
    Net::HTTP.stubs(:get_response).returns(fake_response).times(1).with(URI.parse(url + '&client=-client-id-'))
    
    # perform query
    geocoder = Google4R::Maps::Geocoder.new(key, '-client-id-')
    geocoder.query(@test_adress)
  end
  
  def test_query_without_key_raises_exception
    coder = Google4R::Maps::Geocoder.new(nil)
    
    assert_raises(Google4R::Maps::KeyException) { coder.query("") }
  end
  
  def test_query_with_invalid_key_raises_exception
    coder = Google4R::Maps::Geocoder.new("Invalid Google Maps Key")
    
    assert_raises(Google4R::Maps::KeyException) do
      coder.query(@test_adress)
    end
  end
  
  # Make sure that querying with a broken network connection works, i.e. Google's server
  # is not accessible.
  def test_query_with_broken_network_connection
    Net::HTTP.stubs(:get_response).raises(Net::HTTPRequestTimeOut)

    coder = Google4R::Maps::Geocoder.new(GOOGLE_MAPS_KEY)
    
    assert_raises(Google4R::Maps::ConnectionException) do
      coder.query(@test_adress)
    end
  end
  
  def test_query_returns_nil_if_no_result_has_been_returned_and_no_fatal_problem_occured
    fake_response = mock('fake response')
    fake_response.stubs(:body).returns('')
    Net::HTTP.stubs(:get_response).returns(fake_response)

    [ Google4R::Maps::Geocoder::G_GEO_MISSING_ADDRESS, 
      Google4R::Maps::Geocoder::G_GEO_UNKNOWN_ADDRESS, 
      Google4R::Maps::Geocoder::G_UNAVAILABLE_ADDRESS
    ].each do |code|
      empty_result = @empty_result.dup
      empty_result["Status"]["code"] = code
      
      YAML.stubs(:load).returns(empty_result)

      coder = Google4R::Maps::Geocoder.new(GOOGLE_MAPS_KEY)
    
      assert_nil coder.query(@test_adress)
      assert_equal code, coder.last_status_code
    end
  end
  
  def test_do_query
    coder = Google4R::Maps::Geocoder.new(GOOGLE_MAPS_KEY)
    coder.query @test_adress
    
    assert_equal 200, coder.last_status_code
    
    # no assertion, just make sure that querying works
  end
end
