class Acl < ActiveRecord::Base
  serialize 'permissions'
  def method_missing(method, *args) # {{{
    begin
      super # see if we can execute an ActiveRecord method
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
  def granted?(action, *args) # {{{
    arg = args[0]
    if arg.is_a? Array
      arr  = arg              
      user = User.find(arr[1]) if arg[1] == 'User'
    elsif arg.is_a? User
      arr  = ['User', arg.id]
      user = arg
    end
    begin
      if self.permissions[:granted][action].include?(['User', :any])
        return true
      end
      if self.permissions[:granted][action].include?(arr)
        return true
      end
      self.permissions[:granted][action].each do |a|
        if a[0] == 'Group' && user
          return true if Group.find(a[1]).include?(user)
        end
      end
    rescue
    end
    return false
  end # }}}
  def negated?(action, *args) # {{{
    false
  end # }}}
  def can_do?(action, *args) # {{{
    granted?(action, *args) && !negated?(action, *args)
  end # }}}
  def can_do(action, *args) # {{{
    # TODO implement a generic permission(:grant|:negate, action, *args)
    self.permissions           = {} unless self.permissions
    self.permissions[:granted] = {} unless self.permissions[:granted]
    self.permissions[:negated] = {} unless self.permissions[:negated]
    self.permissions[:granted][action] = [] \
      unless self.permissions[:granted][action]
    self.permissions[:granted][action] << args[0]
  end # }}}
end
