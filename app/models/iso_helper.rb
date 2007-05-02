module ActiveRecord::IsoHelper
  private
  def _before_write # {{{
    self.attributes.each_pair do |key, value|
      begin
        if value.is_a? String
          newval = iso(value)
          #self.send(key + '=', newval)
          self[key.to_sym] = newval
        end
      rescue Iconv::IllegalSequence
      end
    end
  end # }}}
  def _after_read # {{{
    self.attributes.each_pair do |key, value|
      begin
        if value.is_a? String
          newval = utf8(value)
          #self.send(key + '=', newval)
          self[key.to_sym] = newval
        end
      rescue Iconv::IllegalSequence
      end
    end
  end # }}}
  def utf8(string) # {{{
    Iconv.new('utf-8', 'iso-8859-1').iconv(string)
  end # }}}
  def iso(string) # {{{
    Iconv.new('iso-8859-1', 'utf-8').iconv(string)
  end # }}}
end
