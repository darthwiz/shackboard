module FileHelper

  def is_adm?(user=@user)
    @controller.send(:is_adm?, user)
  end

  def icon_selector(object, method, icon=nil)
    s = "<select id='#{object}_#{method}' name='#{object}[#{method}]'>\n"
    FILEDB_ICONS[1].each do |i|
      s << "  <option value='#{i[1]}'"
      s << " selected" if icon == i[1]
      s << ">#{i[0]}</option>\n"
    end
    s << "</select>\n"
  end

  def icon(filename)
    caption = nil
    FILEDB_ICONS[1].each do |i|
      caption = i[0] if filename == i[1]
    end
    filename = '' unless caption
    "<img src='#{FILEDB_ICONS[0]}#{filename}' alt='#{caption}'/>"
  end

  def order_link(text, field)
    fields = [:name, :description, :category, :author, :downloads, :uploader]
    order  = nil
    order  = field if fields.include?(field)
    link_to(text, { :controller => params[:controller],
                    :action     => params[:action],
                    :file       => params[:file],
                    :start      => params[:start],
                    :order      => order } )
  end

  def page_trail_filedb_file(loc, opts={})
    trail  = []
    trail << [ 'Materiali', {:controller => 'file', :action => 'categories'} ]
    if loc.new_record?
      trail << [ "caricamento nuovo file", {} ]
    else
      trail << [ loc.category.name, {:controller => 'file', :action => 'list', :id => loc.category.id} ]
      trail << [ "download di \"#{loc.file_name}\"", {} ]
    end
    trail
  end

  def page_trail_filedb_category(loc, opts={})
    trail  = []
    trail << [ 'Materiali', {:controller => 'file', :action => 'categories'} ]
    trail << [ loc.name, {} ]
    trail
  end

  def page_trail_filedb_categories(loc, opts={})
    trail  = []
    trail << [ 'Materiali', {} ]
    trail
  end

end
