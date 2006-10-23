class Acl < ActiveRecord::Base
  serialize 'permissions'
  def method_missing(method, *args) # {{{
    begin
      super
    rescue Exception => e
      action = method.to_s.sub(/^can_/, '').sub(/\?$/, '').to_sym
      if (method.to_s =~ /^can_[[:alnum:]_]+\?$/)
        can_do?(action, *args)
      elsif (method.to_s =~ /^can_[[:alnum:]_]+$/)
        can_do(action, *args)
      else
        raise e
      end
    end
  end # }}}
private
  def can_do?(action, *args) # {{{
    arg = args[0]
    arr = arg            if arg.is_a? Array
    arr = [User, arg.id] if arg.is_a? User
    begin
      if self.permissions[:granted][action].include?([User, :any])
        return true
      end
      if self.permissions[:granted][action].include?(arr)
        return true
      end
    rescue
      return false
    end
    return false
  end # }}}
  def can_do(action, *args) # {{{
    self.permissions           = {} unless self.permissions
    self.permissions[:granted] = {} unless self.permissions[:granted]
    self.permissions[:negated] = {} unless self.permissions[:negated]
    self.permissions[:granted][action] = [] \
      unless self.permissions[:granted][action]
    self.permissions[:granted][action] << args[0]
  end # }}}
end
