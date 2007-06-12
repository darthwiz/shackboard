module FileHelper
  def is_adm?(user=@user) # {{{
    @controller.send(:is_adm?, user)
  end # }}}
  def icon_selector(object, method, icon=nil) # {{{
    s = "<select id='#{object}_#{method}' name='#{object}[#{method}]'>\n"
    FILEDB_ICONS[1].each do |i|
      s << "  <option value='#{i[1]}'"
      s << " selected" if icon == i[1]
      s << ">#{i[0]}</option>\n"
    end
    s << "</select>\n"
  end # }}}
  def icon(filename) # {{{
    caption = nil
    FILEDB_ICONS[1].each do |i|
      caption = i[0] if filename == i[1]
    end
    filename = '' unless caption
    "<img src='#{FILEDB_ICONS[0]}#{filename}' alt='#{caption}'/>"
  end # }}}
  def order_link(text, field) # {{{
    fields = [:name, :description, :category, :author, :downloads, :uploader]
    order  = nil
    order  = field if fields.include?(field)
    link_to(text, { :controller => params[:controller],
                    :action     => params[:action],
                    :file       => params[:file],
                    :start      => params[:start],
                    :order      => order } )
  end # }}}
  def page_trail_File(loc) # {{{
    trail  = []
    if loc == :categories
      trail << [ 'Area file', {} ]
    else
      trail << [ 'Area file', {:controller => 'file', :action => 'categories'} ]
    end
    if loc == :confirm_license
      trail << [ @file.category.name, {:controller => 'file', :action => 'list',
        :id => @file.category.id} ]
      trail << [ "download di \"#{@file.file_name}\"", {} ] 
    end
    trail << [ 'caricamento nuovo file', {} ] if loc == :upload
    trail << [ 'risultati ricerca', {} ]      if loc == :search_results
    trail << [ loc.cat_name, {} ]             if loc.is_a? FiledbCategory
    trail
  end # }}}
end
