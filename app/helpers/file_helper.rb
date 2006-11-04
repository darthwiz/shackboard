# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include ActionView::Helpers::UrlHelper
  def is_adm?(user=@user) # {{{
    FiledbAdmin.is_adm?(user)
  end # }}}
end
