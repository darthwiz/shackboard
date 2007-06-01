module ActiveRecord::EachBy
  def method_missing(method, *args, &block) # {{{
    begin
      super
    rescue Exception => e
      if method.to_s =~ /^each_by_/
        field = method.to_s.sub(/^each_by_/, '').to_sym
        return each_by_field(field, args, &block)
      else
        raise e
      end
    end
  end # }}}
  private
  def each_by_field(field, args) # {{{
    raise InvalidFieldError, "no field named #{field.to_s.inspect}" \
      unless self.new.attribute_names.include?(field.to_s)
    value  = args.first
    conds  = [ "#{field} = ?", value ]
    count  = count(:conditions => conds)
    offset = 0
    limit  = 50
    while offset <= count
      find(
        :all,
        :conditions => conds,
        :offset     => offset,
        :limit      => limit
      ).each { |p| yield p }
      offset += limit
      puts "#{self.new.class}: #{offset}"
    end
    nil
  end # }}}
end

class InvalidFieldError < StandardError; end
