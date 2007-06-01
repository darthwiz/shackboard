module ActiveRecord::StripHelper
  private
  def strip_slashes # {{{
    self.attributes.each_pair do |key, value|
      if value.is_a? String
        newval = value.gsub(/\\'/, "'").gsub(/\\"/, '"')
        self.send(key + '=', newval)
      end
    end
  end # }}}
end
