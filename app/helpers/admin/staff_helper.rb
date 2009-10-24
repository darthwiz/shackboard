module Admin::StaffHelper

  def page_trail_admin_staff(obj, opts={})
    [ [ "Amministrazione", admin_path ], [ "Staff", nil ] ]
  end

end
