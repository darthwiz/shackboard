module GroupHelper
  def is_adm?(user=@user) # {{{
    @controller.send(:is_adm?, user)
  end # }}}
  def can_edit?(group, user=@user) # {{{
    @controller.send(:can_edit?, group, user)
  end # }}}
end
