#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/boot'
require "#{RAILS_ROOT}/config/environment"
#ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'
ENV['RAILS_ENV'] = 'development'
