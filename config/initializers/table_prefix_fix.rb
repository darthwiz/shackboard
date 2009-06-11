require 'active_record/migration'

module ActiveRecord
  
  class Migrator#:nodoc:
  
    class << self
 
      # overide to check for table name propriety
      def proper_table_name( name )
        name.table_name rescue make_proper_table_name( name )
      end
    
      def make_proper_table_name( name )
        is_proper_table_name?( name ) ? name : 
          "#{ActiveRecord::Base.table_name_prefix}#{name}#{ActiveRecord::Base.table_name_suffix}"
      end  
      
      def is_proper_table_name?( name )
        name_string = name.to_s
        
        (not name_string.empty?) and 
          name_string.starts_with?( "#{ActiveRecord::Base.table_name_prefix}" ) and 
          name_string.ends_with?( "#{ActiveRecord::Base.table_name_suffix}" )
      end
  
    end
  end
end