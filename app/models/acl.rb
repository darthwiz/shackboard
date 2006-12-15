class Acl < ActiveRecord::Base
  serialize 'permissions'
  def method_missing(method, *args) # {{{
    begin
      super # see if we can call an ActiveRecord method
    rescue Exception => e
      action = method.to_s.sub(/^(remove_)?cant?_/, '').sub(/\?$/, '').to_sym
      if (method.to_s =~ /^can_[[:alnum:]_]+\?$/)
        can_do?(action, *args)
      elsif (method.to_s =~ /^can_[[:alnum:]_]+$/)
        add_perm(:granted, action, *args)
      elsif (method.to_s =~ /^cant_[[:alnum:]_]+$/)
        add_perm(:negated, action, *args)
      elsif (method.to_s =~ /^remove_can_[[:alnum:]_]+$/)
        remove_perm(:granted, action, *args)
      elsif (method.to_s =~ /^remove_cant_[[:alnum:]_]+$/)
        remove_perm(:negated, action, *args)
      else
        raise e
      end
    end
  end # }}}
private
  def perm?(type, action, *args) # {{{
    arg  = args[0]
    arr  = arg_to_array(arg)
    user = arg if arg.is_a? User
    user = User.find(arr[1]) if (arg[0] == 'User' && arg[1].is_a?(Fixnum))
    begin
      if self.permissions[type][action].include?(['User', :any])
        return true
      end
      if self.permissions[type][action].include?(arr)
        return true
      end
      self.permissions[type][action].each do |a|
        if a[0] == 'Group' && user
          return true if Group.find(a[1]).include?(user)
        end
      end
    rescue
    end
    return false
  end # }}}
  def add_perm(type, action, *args) # {{{
    add                            = arg_to_array(args[0])
    self.permissions               = {} unless self.permissions
    self.permissions[:granted]     = {} unless self.permissions[:granted]
    self.permissions[:negated]     = {} unless self.permissions[:negated]
    self.permissions[type][action] = [] unless self.permissions[type][action]
    self.permissions[type][action] << add
    self.save unless self.new_record?
  end # }}}
  def remove_perm(type, action, *args) # {{{
    self.permissions[type][action].delete(args[0])
    self.save unless self.new_record?
  end # }}}
  def can_do?(action, *args) # {{{
    perm?(:granted, action, *args) && !perm?(:negated, action, *args)
  end # }}}
  def arg_to_array(arg) # {{{
    case arg.class.to_s
    when 'Array'
      arr = arg
    else
      arr = [ arg.class.to_s, arg.id ]
    end
  end # }}}
end
