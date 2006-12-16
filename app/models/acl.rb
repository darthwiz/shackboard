class Acl < ActiveRecord::Base
  serialize 'permissions'
  def save # {{{
    previously_new = self.new_record?
    super
    AclMapping.associate!(@owner, self) if (@owner && previously_new)
  end # }}}
  def attach_to(object) # {{{
    @owner = object
    self
  end # }}}
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
    arr = arg_to_array(args[0])
    begin
      if self.permissions[type][action].include?(['User', :any])
        return true
      end
      if self.permissions[type][action].include?(arr)
        return true
      end
      self.permissions[type][action].each do |a|
        if a[0] == 'Group'
          return true if Group.find(a[1]).include?(arr)
        end
      end
    rescue
    end
    return false
  end # }}}
  def add_perm(type, action, *args) # {{{
    add                            = arg_to_array(args[0])
    self.permissions               = {} unless self.permissions
    self.permissions[type]         = {} unless self.permissions[type]
    self.permissions[type][action] = [] unless self.permissions[type][action]
    self.permissions[type][action] << add
  end # }}}
  def remove_perm(type, action, *args) # {{{
    arg = arg_to_array(args[0])
    self.permissions[type][action].delete(arg)
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
