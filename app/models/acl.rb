class Acl < ActiveRecord::Base
  set_table_name table_name_prefix + 'acl'
  serialize 'permissions'
  def method_missing(method, args = nil) # {{{
    if (method.to_s =~ /^can_[[:alnum:]]+\?$/)
      puts method
    else
      raise
    end
  end # }}}
end
