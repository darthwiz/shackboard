class PortalAdminGroupAffiliation < ActiveRecord::Base
  require 'iso_helper.rb'
  include ActiveRecord::IsoHelper
  set_table_name       'portal_admin_groups'
  belongs_to           :user
  def associate(user) # {{{
    raise ArgumentError, 'Argument is not a User' unless user.is_a? User
    self.user     = user
    self.username = user.username
  end # }}}
end
