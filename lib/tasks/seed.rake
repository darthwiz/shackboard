# http://derekdevries.com/2009/04/13/rails-seed-data/
require 'active_record/fixtures'
 
namespace :db do
  namespace :seed do

    desc "Seed the database with once/ and always/ fixtures."
    task :init => :environment do 
      load_fixtures "seed/once"
      load_fixtures "seed/always", :always
    end
  
    desc "Seed the database with development/ fixtures."
    task :development => :environment do 
      load_fixtures 'seed/development', :always
    end
  
  
    private
  
    def load_fixtures(dir, always = false)
      Dir.glob(File.join(RAILS_ROOT, 'db', dir, '*.yml')).each do |fixture_file|
        table_name = File.basename(fixture_file, '.yml')
  
        if table_empty?(table_name) || always
          truncate_table(table_name)
          Fixtures.create_fixtures(File.join('db/', dir), table_name)
        end
      end
    end  
  
    def table_empty?(table_name)
      table_name = ActiveRecord::Base.table_name_prefix + table_name
      quoted = connection.quote_table_name(table_name)
      connection.select_value("SELECT COUNT(*) FROM #{quoted}").to_i.zero?
    end
  
    def truncate_table(table_name)
      table_name = ActiveRecord::Base.table_name_prefix + table_name
      quoted = connection.quote_table_name(table_name)
      connection.execute("DELETE FROM #{quoted}")
    end
  
    def connection
      ActiveRecord::Base.connection
    end
  end
end
