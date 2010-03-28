require "#{RAILS_ROOT}/config/environment"
ENV['RAILS_ENV'] = ENV['RAILS_ENV'] || 'development'
require 'find'

namespace :db do
  namespace :fixtures do
    desc 'Dumps all models into fixtures.'
    task :dump => :environment do
      models = []
      Find.find(RAILS_ROOT + '/app/models') do |path|
        unless File.directory?(path) || path =~ /\.svn/
          m = path.match(/(\w+).rb/)
          models << m[1] unless m.nil?
        end
      end
  
      if ENV['ONLY']
        required_models = ENV['ONLY'].split(',').map {|m| m.strip.underscore }
        models = (models & required_models)         
        raise "Can't find all of these models: #{required_models.join(', ')}" unless (required_models - models).empty?
      end
      
      models -= ENV['EXCEPT'].split(',').map {|m| m.strip.underscore } if ENV['EXCEPT']        
      puts "Using models: " + models.join(', ')
 
      models.each do |m|
        puts "Dumping model: " + m
        model = Module.const_get(m.classify)
        entries = model.find(:all, :order => model.primary_key + ' ASC')
        
        formatted, increment, tab = '', 1, '  '
        entries.each do |a|
          formatted += m + '_' + increment.to_s + ':' + "\n"
          increment += 1
          
          a.attributes.each do |column, value|
            formatted += tab
            
            match = value.to_s.match(/\n/)
            if match
              formatted += column + ': |' + "\n"
              
              value.to_a.each do |v|
                formatted += tab + tab + v
              end
            else
              formatted += column + ': ' + value.to_s
            end
            
            formatted += "\n"
          end
                    
          formatted += "\n"
        end
      
        model_file = RAILS_ROOT + '/test/fixtures/' + m.pluralize + '.yml'
        
        File.exists?(model_file) ? File.delete(model_file) : nil
        File.open(model_file, 'w') {|f| f << formatted}
      end
    end
  end
end
