#require 'lingua/stemmer'

class QueryString
  def initialize(string='')
    @original_string = string
  end
  def to_mysql
    #stemmer = Lingua::Stemmer.new(:language => 'it')
    words   = @original_string.unaccent.downcase.gsub(/[^a-z0-9-]/, ' ').split(/\s+/).select { |i| i.strip.length > 1 }
    pieces  = words.collect do |i| 
      if i =~ /-/
        "+\"#{i}\""
      else
        #"+#{stemmer.stem(i)}*"
        "+\"#{i}\""
      end
    end
    pieces.join(' ')
  end
end
